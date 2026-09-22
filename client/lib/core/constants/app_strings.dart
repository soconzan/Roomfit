class AppStrings {
  AppStrings._();

  // App
  static const String kAppName = 'roomfit';

  // Bottom Navigation Bar
  static const String kNavHome = '홈';
  static const String kNavCategory = '카테고리';
  static const String kNavRecommend = '추천';
  static const String kNavProfile = 'MY';

  // Home Screen
  static const String kHomeBannerTitle = '내 공간에 딱✨ 맞는\n가구 찾기';

  // Product Create Screen
  static const String kProductCreateTitle = '내 가구 팔기';
  static const String kProductCreateRepresentative = '대표';
  static const String kProductCreatePhotoSuffix = '/10';
  static const String kProductCreateLabelTitle = '제목';
  static const String kProductCreateTitleHint = '제목을 입력해주세요.';
  static const String kProductCreateLabelCategory = '카테고리';
  static const String kProductCreateCategoryHint = '선택';
  static const String kProductCreateLabelDescription = '설명';
  static const String kProductCreateDescriptionHint =
      '게시글 내용을 작성해 주세요.\n신뢰할 수 있는 거래를 위해 자세히 적어주세요.';
  static const String kProductCreateLabelPrice = '가격';
  static const String kProductCreatePriceHint = '가격 입력';
  static const String kProductCreatePricePrefix = '₩';
  static const String kProductCreateLabelWidth = '가로';
  static const String kProductCreateLabelDepth = '세로';
  static const String kProductCreateLabelHeight = '높이';
  static const String kProductCreateSizeSuffix = 'cm';
  static const String kProductCreateLabelMaterial = '소재';
  static const String kProductCreateMaterialHint =
      '소재를 입력해주세요. (예: 원목, 패브릭, 철제)';
  // Product Edit Screen
  static const String kProductEditSubmit = '수정 완료';
  static const String kProductEdit3dButton = '3D 모델 재생성하기';
  static const String kProductEdit3dButtonReady = '재생성 준비 완료';

  static const String kProductCreate3dButton = '3D 모델 생성하기';
  static const String kProductCreate3dButtonReady = '3D 모델 생성 준비 완료';
  static const String kProductCreate3dNote = '3D 모델이 완성되면 알림을 보내드려요';
  static const String kProductCreateSubmit = '작성 완료';

  // Auth Screen
  static const String kLoginTitle = 'Login';
  static const String kLoginId = '아이디';
  static const String kLoginIdHint = 'example';
  static const String kLoginPassword = '비밀번호';
  static const String kLoginPasswordHint = '8자 이상 입력';
  static const String kLoginButton = '로그인';
  static const String kLoginError = '아이디 또는 비밀번호를 확인해주세요.';
  static const String kLoginSignupPrompt = '회원이 아니신가요?';
  static const String kLoginSignupLink = '회원가입';
  static const String kSignupTitle = '회원가입';
  static const String kSignupNickname = '닉네임';
  static const String kSignupNicknameHint = '홍길동';
  static const String kSignupConfirmPassword = '비밀번호 확인';
  static const String kSignupConfirmPasswordHint = '비밀번호를 다시 입력';
  static const String kSignupButton = '가입하기';
  static const String kSignupPasswordMismatch = '비밀번호가 일치하지 않습니다.';
  static const String kSignupError = '회원가입에 실패했습니다.';
  static const String kSignupLoginPrompt = '이미 계정이 있으신가요?';

  // Product Detail Screen
  static const String kDetail3dViewer = '3D 뷰어';
  static const String kViewerLabel3d = '3D';
  static const String kViewerLabelAr = 'AR';
  static const String kDetailEditPost = '게시글 수정';
  static const String kDetailDeletePost = '삭제';
  static const String kDetailClose = '닫기';
  static const String kDetailError = '상품 정보를 불러올 수 없습니다.';
  static const String kDetailDeleteSuccess = '삭제되었습니다.';
  static const String kDetailDeleteError = '삭제에 실패했습니다.';

  // Profile Screen
  static const String kProfileTitle = 'my page';
  static const String kProfileSales = '판매물품';
  static const String kProfileEmpty = '등록한 물품이 없습니다.';
  static const String kProfileLogout = '로그아웃';
  static const String kProfileError = '오류가 발생했습니다.';

  // Modeling Camera Screen
  static const String kModelingCameraSingleTitle = '제품 정면을 촬영하세요';
  static const String kModelingCameraHint =
      '💡 제품이 잘리거나 흐릿한 사진은 모델 생성 시 정확도가 떨어져요';

  // Category Screen
  static const String kCategoryTitle = '카테고리';
  static const String kCategoryAllTab = '전체';
  static const String kCategoryEmpty = '등록된 상품이 없습니다.';

  // Search Screen
  static const String kSearchHint = '키워드를 입력하세요';
  static const String kSearchRecentTitle = '최근 검색';
  static const String kSearchEmpty = '검색 결과가 없습니다.';
  static const String kSearchError = '오류가 발생했습니다.';

  // Seller Profile Screen
  static const String kSellerProfileTitle = '프로필';

  // Recommend Screen
  static const String kRecommendTitle = '원하는 가구가\n있으신가요?';
  static const String kRecommendSubtitle = '공간에 어울리는 가구를 더 정확하게 추천할 수 있어요';
  static const String kRecommendNoCategory = '특별히 원하는 카테고리가 없어요';
  static const String kRecommendButton = '공간 촬영하기';

  // Modeling Screen
  static const String kModelingTitle = '3D 모델 생성하기';
  static const String kModelingRecommendNote =
      '정확한 3D 모델 생성을 위해 멀티뷰 촬영을 권장합니다.';
  static const String kModelingSingleView = '싱글뷰\n촬영하기';
  static const String kModelingMultiView = '멀티뷰\n촬영하기';
  static const String kModelingAlbum = '앨범에서 가져오기';
  static const String kModelingNoteTitle = '앨범 선택 시 주의사항';
  static const List<String> kModelingNoteItems = [
    '제품이 전체가 잘 보이도록 촬영된 사진을 사용해주세요.',
    '제품이 잘리거나 일부만 보이는 사진은 정확한 모델 생성이 어렵습니다.',
    '배경과 제품이 명확히 구분되는 사진이 좋습니다.',
    '흐리거나 흔들린 사진은 정확도가 떨어질 수 있습니다.',
  ];
}
