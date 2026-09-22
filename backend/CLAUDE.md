# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# 빌드
./gradlew build

# 실행
./gradlew bootRun

# 테스트
./gradlew test

# 단일 테스트 클래스 실행
./gradlew test --tests "org.example.roomfit.RoomFitApplicationTests"
```

**Java 21 / Spring Boot 4.0.4** 기반이며, `application-secret.properties`가 없으면 앱이 시작되지 않는다 (`spring.profiles.include=secret`).

## 외부 의존 서비스

앱 구동 시 아래 두 개의 외부 AI 서버가 필요하다:

| 서버 | 기본 URL | 역할 |
|------|----------|------|
| FastAPI (VisionServiceClient) | `${fastapi.server.url}` (secret) | 배경 제거(`/remove-background`), CLIP 임베딩 추출(`/extract-features`), 색상 추출(`/extract-dominant-colors`) |
| Grounded-SAM (GroundedSAMClient) | `${grounded-sam.api.url}` (기본값 `localhost:8002`) | 이미지 내 객체 감지 및 세그멘테이션(`/segment`) |

Firebase Admin SDK의 서비스 계정 키 파일은 `src/main/resources/firebase/firebase-service-account.json`에 위치해야 한다.

## 아키텍처

### 레이어 구조

표준 Spring 레이어드 아키텍처 (`controller → service → repository`)를 따른다. `service/` 패키지 안에 외부 AI 서버 클라이언트(`GroundedSAMClient`, `VisionServiceClient`)도 함께 포함되어 있다.

### 핵심 추천 플로우 (`RecommendService`)

1. 요청받은 사이즈(width/depth/height)에 맞는 상품이 DB에 존재하는지 사전 확인
2. **병렬 실행** (`CompletableFuture`):
   - `GroundedSAMClient.segmentImage()` → 방 사진에서 가구 객체 감지
   - `VisionServiceClient.extractDominantColors()` → 방의 주조색(HSV) 추출
3. 감지된 각 객체에 대해 CLIP 임베딩 추출 후 평균하여 단일 벡터로 혼합
4. 색상 유사도 판단: 두 주조색이 비슷하면 반대 색상(H+180°) 추천, 다르면 주조색 유지
5. `ProductRepository`의 native 쿼리로 pgvector 코사인 유사도 + L2 색상 거리 결합 점수 계산
   - 최종 점수 = `0.6 × CLIP 유사도 + 0.4 × 색상 유사도`
   - `<=>` 연산자: 코사인 거리 (image_embedding), `<->` 연산자: L2 거리 (color_vector)

### 상품 이미지 비동기 처리 파이프라인

상품 등록 시 이미지 처리는 즉시 반환 후 비동기로 진행된다 (`@Async`):

```
상품 저장 (vision_status=PENDING)
  → processImageAsync()
    → 배경 제거 (FastAPI)
    → CLIP 임베딩 추출 (FastAPI)
    → 색상 추출 (FastAPI)
    → vision_status=DONE, 결과 저장
```

실패 시 `VisionProcessingScheduler`가 5분(`fixedDelay=300000`)마다 `vision_status=FAILED AND retry_count<3` 조건의 상품을 재시도한다.

### 인증 흐름

1. 클라이언트가 Firebase ID 토큰을 `AuthController`로 전송
2. `AuthService`가 Firebase Admin SDK로 토큰 검증 후 자체 JWT 발급
3. 이후 요청은 `JwtAuthenticationFilter`에서 JWT 검증

### 데이터베이스

PostgreSQL + pgvector 확장을 사용한다. 벡터 컬럼과 인덱스:
- `products.image_embedding vector(768)` — HNSW 코사인 인덱스
- `products.color_vector_1/2/3 vector(3)` — HNSW L2 인덱스 (HSV 색상)
- `categories.embedding vector(768)` — 카테고리 텍스트 임베딩 (앱 시작 시 `CategoryEmbeddingInitializer`로 초기화)

이미지 파일은 Cloudflare R2 (S3 호환 API)에 저장되며, `R2Service`가 업로드/다운로드를 담당한다.

### 정적 HTML 테스트 페이지

`src/main/resources/static/`에 개발용 HTML 페이지들이 있다 (`createProduct.html`, `recommendProduct.html` 등). 별도 프론트엔드 없이 API를 직접 테스트할 때 사용한다.
