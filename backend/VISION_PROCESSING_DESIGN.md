## 비동기 이미지 처리 및 재시도 설계 요약

### 1. 상태 추적 구조

#### 데이터베이스 컬럼 추가 (products 테이블)
- `vision_status`: PENDING, PROCESSING, DONE, FAILED 중 하나
- `vision_retry_count`: 재시도 횟수 (최대 3회)
- `vision_last_attempt_at`: 마지막 처리 시각
- `vision_error_message`: 실패 원인

---

### 2. 상태 전이 흐름

#### 상품 생성 직후
```
saveProduct() 호출
├── 상품 기본 정보 저장
├── vision_status = PENDING
├── vision_retry_count = 0
└── 이미지 파일 저장 후 비동기 처리 트리거
```

#### 비동기 처리 시작
```
processImageAsync(productId, byte[], filename) 호출
├── vision_status = PROCESSING으로 업데이트
├── vision_last_attempt_at = 현재 시각
├── 배경 제거 (removeBackgroundFromFastApi)
├── 임베딩 추출 (getEmbeddingFromFastApi)
├── 색상 추출 (extractDominantColors)
└── 결과 저장
```

#### 성공 시
```
vision_status = DONE
vision_error_message = null
image_embedding / color_vector_1~3 저장
```

#### 실패 시
```
vision_status = FAILED
vision_retry_count += 1
vision_error_message = 예외 메시지
vision_last_attempt_at = 현재 시각
```

---

### 3. 재시도 메커니즘

#### 재시도 타이밍 (5분마다)
`VisionProcessingScheduler` 클래스가 `@Scheduled(fixedDelay = 300000)`로 작동

#### 재시도 대상 조건
```
vision_status = 'FAILED'
AND vision_retry_count < 3
AND (vision_last_attempt_at IS NULL OR vision_last_attempt_at <= now() - 5분)
```

#### 재시도 프로세스
1. 실패한 상품 목록 조회
2. 각 상품마다:
   - 썸네일 이미지 URL 조회
   - R2에서 이미지 다운로드
   - processImageAsync() 다시 호출
3. 성공/실패 상태 업데이트

---

### 4. 핵심 클래스 및 메서드

#### ProductService
- `saveProduct()`: 상품 저장 (빠르게 반환) → 비동기 처리 트리거
- `processImageAsync()`: 비전 처리 비동기 실행
- `extractBytes()`: MultipartFile을 안전하게 byte[]로 변환

#### VisionProcessingScheduler
- `retryFailedVisionProcessing()`: 5분마다 실패 상품 재시도

#### VisionServiceClient
- `removeBackgroundFromFastApi(Resource)`: Resource 버전 추가
- `getEmbeddingFromFastApi(byte[], String)`: 이미 지원
- `extractDominantColors(byte[], String)`: 이미 지원

#### R2Service
- `downloadFile(String)`: R2에서 파일 다운로드 추가

#### ProductRepository
- `findFailedVisionProducts()`: 재시도 대상 조회

---

### 5. 장점

✅ 상품 생성 응답이 빠름 (vision 처리 비동기)
✅ vision 처리 실패 시 자동으로 재시도 (최대 3회)
✅ 상태 추적으로 운영이 쉬움
✅ 중복 실행 방지 (vision_status = PROCESSING)
✅ 에러 원인 기록 (vision_error_message)

---

### 6. 사용자 경험

1. 사용자가 상품 등록
2. 바로 성공 응답 받음
3. 백그라운드에서 이미지 분석 진행
4. 분석 완료 후 embedding/color 반영
5. 실패 시 자동 재시도

---

### 7. 모니터링 포인트

- `vision_status = FAILED` AND `vision_retry_count >= 3`: 영구 실패 상품 확인
- `vision_status = PROCESSING` AND `vision_last_attempt_at` 오래됨: 무한 루프 확인
- `vision_error_message`: 실패 원인 분석

