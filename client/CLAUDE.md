# RoomFit 프로젝트

## 기술 스택
- Flutter SDK
- 상태관리: flutter_riverpod
- 라우팅: go_router
- 네트워크: dio
- 모델: freezed + json_serializable
- 로컬저장: shared_preferences
- 이미지: cached_network_image
- 유니티 연동: flutter_embed_unity
- 3D viewer : model_viewer_plus

## 디렉토리 구조
android/unityLibrary     # unity project
lib/
├── core/
│   ├── constants/       # AppColors, AppSizes, AppStrings, AppApi
│   ├── network/         # DioClient (dioProvider 포함)
│   ├── router/          # AppRouter (go_router)
│   └── theme/           # AppTheme
├── shared/
│   └── presentation/
│       └── widgets/     # 공통 위젯
├── unity/builds/android/
└── features/
    ├── auth/
    │   ├── domain/
    │   │   ├── entities/        # 
    │   │   ├── repositories/    # 
    │   │   └── usecases/        #
    │   ├── data/
    │   │   ├── models/          #    
    │   │   ├── sources/remote/  #
    │   │   └── repositories/    #
    │   └── presentation/
    │       ├── screen/          #
    │       ├── widgets/         #
    │       └── provider/        #
    ├── product/
    │   ├── domain/
    │   │   ├── entities/        # 
    │   │   ├── repositories/    #
    │   │   └── usecases/        #
    │   ├── data/
    │   │   ├── models/          #
    │   │   ├── sources/remote/  #
    │   │   └── repositories/    #
    │   └── presentation/
    │       ├── screen/          #
    │       └── provider/        #
    ├── home/
    │   └── presentation/screen/ #
    ├── chat/
    │   └── presentation/screen/ #
    ├── discovery/
    │   └── presentation/screen/ #
    ├── modeling/
    │   └── presentation/screen/ #
    └── profile/
        └── presentation/screen/ #

## 공통 위젯 목록 (presentation/common/widgets/)
- app_bottom_nav_bar.dart  # 하단 네비게이션 (홈/카테고리/탐색/MY)
- product_create_fab.dart  # 우하단 + 버튼
- product_list_itme.dart   # 

## 코드 규칙
- 파일명/변수명: snake_case
- 클래스명: PascalCase
- 색상: AppColors 상수 사용 (하드코딩 금지)
- 간격: AppSizes 상수 사용 (하드코딩 금지)
- 문자열: AppStrings 상수 사용 (하드코딩 금지)
- 위젯: StatelessWidget 우선, 상태 필요시 ConsumerWidget
- 비동기: AsyncNotifierProvider 사용
- 주석: 한국어 작성
- 모든 파일 위치는 Clean Architecture를 따름

## 디버그 로그 컨벤션

- `print()` 대신 `debugPrint()` 사용 (긴 로그 잘림 방지)
- 이모지 prefix로 로그 레벨 구분:
  - 🔴 [ERROR] 오류 발생
  - 🟡 [WARN]  경고
  - 🟢 [INFO]  일반 정보
  - 🔵 [AUTH]  인증 관련

예시:
debugPrint('🟢 [INFO] 상품 목록 로드 완료: ${products.length}개');
debugPrint('🔴 [ERROR] Dio 실패: $e');
debugPrint('🔵 [AUTH] 리프레시 토큰 시도');