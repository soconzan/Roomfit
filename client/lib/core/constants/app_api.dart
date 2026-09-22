class AppApi {
  AppApi._();

  static const String baseUrl = 'http://158.179.167.248:8080';
  // static const String baseUrl = 'http://localhost:8080';

  // Auth
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authCheckId = '/api/auth/check-id';
  static const String authCheckName = '/api/auth/check-name';

  static const String authRefresh = '/api/auth/refresh';

  // FCM
  static const String fcmToken = '/api/fcm/token';

  // Users
  static const String userMe = '/api/users/me';

  // Categories
  static const String categories = '/api/categories';

  // Products
  static const String products = '/api/products';
  static String productDetail(int id) => '/api/products/$id';
  static String updateProduct(int id) => '/api/products/$id';
  static String productModel(int id) => '/api/products/$id/model';
  static const String createProduct = '/api/products';
  static const String productSearch = '/api/products/search';
  static const String myProducts = '/api/products/me';

  // Recommend
  static const String recommend = '/api/recommend';

  // Deep Links (이 앱 호출)
  static const String deepLinkHome = 'roomfit-client://home';
  static String deepLinkProductDetail(int id) => 'roomfit-client:///products/$id';

  // Deep Links (AR App)
  static const String arDetailBase = 'roomfitar://open?mode=detail';
  static const String arRecommendBase = 'roomfitar://open?mode=recommend';

  static String arDetailLink({
    required int productId,
    required String modelUrl,
    required double width,
    required double height,
    required double depth,
  }) {
    final encoded = Uri.encodeComponent(modelUrl);
    return '$arDetailBase'
        '&productId=$productId'
        '&modelUrl=$encoded'
        '&width=$width'
        '&height=$height'
        '&depth=$depth';
  }

  static String arRecommendLink({int? categoryId}) =>
      categoryId != null
          ? '$arRecommendBase&categoryId=$categoryId'
          : arRecommendBase;
}
