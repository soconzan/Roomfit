import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/auth/presentation/screen/login_screen.dart';
import 'package:roomfit_client/features/auth/presentation/screen/signup_screen.dart';
import 'package:roomfit_client/features/recommend/presentation/screen/recommend_category_screen.dart';
import 'package:roomfit_client/features/recommend/presentation/screen/recommend_result_screen.dart';
import 'package:roomfit_client/features/home/presentation/screen/home_screen.dart';
import 'package:roomfit_client/features/modeling/presentation/screen/modeling_camera_multi_screen.dart';
import 'package:roomfit_client/features/modeling/presentation/screen/modeling_camera_single_screen.dart';
import 'package:roomfit_client/features/modeling/presentation/screen/modeling_create_album_screen.dart';
import 'package:roomfit_client/features/modeling/presentation/screen/modeling_create_single_screen.dart';
import 'package:roomfit_client/features/modeling/presentation/screen/modeling_method_screen.dart';
import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_create_screen.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_edit_screen.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_3d_viewer_screen.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_detail_screen.dart';
import 'package:roomfit_client/features/category/presentation/screen/category_products_screen.dart';
import 'package:roomfit_client/features/category/presentation/screen/category_screen.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_search_result_screen.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_search_screen.dart';
import 'package:roomfit_client/features/profile/presentation/screen/my_products_screen.dart';
import 'package:roomfit_client/features/profile/presentation/screen/profile_screen.dart';
import 'package:roomfit_client/features/profile/presentation/screen/seller_profile_screen.dart';
import 'package:roomfit_client/shared/presentation/widgets/app_bottom_nav_bar.dart';

abstract class AppPaths {
  static const String home = '/home';
  static const String product = '/product';
  static const String productSearch = '/product/search';
  static const String productCreate = '/product-create';
  static const String productEdit = '/product-edit/:id';
  static String productEditPath(int id) => '/product-edit/$id';
  static const String productDetail = '/products/:id';
  static const String product3dViewer = '/product-3d-viewer/:id';

  static String product3dViewerPath(int id) => '/product-3d-viewer/$id';

  static String productDetailPath(int id) => '/products/$id';
  static const String sellerProfile = '/sellers/:userId';
  static String sellerProfilePath(String userId) => '/sellers/$userId';
  static const String myProducts = '/my-products';
  static const String recommend = '/recommend';
  static const String recommendCategory = '/recommend-category';
  static const String recommendResult = '/recommend-result';
  static const String profile = '/profile';
  static const String modelingMethod = '/modeling-method';
  static const String modelingCameraSingle = '/modeling-camera-single';
  static const String modelingCameraMulti = '/modeling-camera-multi';
  static const String modelingCreateAlbum = '/modeling-create-album';
  static const String modelingCreateSingle = '/modeling-create-single';
  static const String productCategory = '/product/category';
  static const String productSearchResult = '/product-search-result';
  static const String login = '/login';
  static const String signup = '/signup';
}

final GoRouter appRouter = GoRouter(
  restorationScopeId: 'roomfit_router',
  initialLocation: AppPaths.home,
  redirect: (context, state) {
    final path = state.uri.path;
    final host = state.uri.host;
    // roomfit-client://home → 홈으로 이동
    if (host == 'home') return AppPaths.home;
    if (path == '/') return AppPaths.home;
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'main_shell',
      builder: (context, state, navigationShell) {
        return _ShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          restorationScopeId: 'home_branch',
          routes: [
            GoRoute(
              path: AppPaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'product_branch',
          routes: [
            GoRoute(
              path: AppPaths.product,
              builder: (context, state) => const CategoryScreen(),
              routes: [
                GoRoute(
                  path: 'category',
                  builder: (context, state) {
                    final categoryId = state.extra! as int;
                    return CategoryProductsScreen(
                      initialCategoryId: categoryId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'recommend_branch',
          routes: [
            GoRoute(
              path: AppPaths.recommend,
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'profile_branch',
          routes: [
            GoRoute(
              path: AppPaths.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppPaths.productCreate,
      builder: (context, state) {
        final photos = state.extra as List<LabeledPhoto>?;
        return _BackToHomeOnRootPop(
          child: ProductCreateScreen(initialPhotos: photos),
        );
      },
    ),
    GoRoute(
      path: AppPaths.productEdit,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final detail = state.extra! as ProductDetail;
        return _BackToHomeOnRootPop(
          child: ProductEditScreen(productId: id, detail: detail),
        );
      },
    ),
    GoRoute(
      path: AppPaths.productDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _BackToHomeOnRootPop(child: ProductDetailScreen(id: id));
      },
    ),
    GoRoute(
      path: AppPaths.product3dViewer,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final extra = state.extra as Map<String, dynamic>?;
        return _BackToHomeOnRootPop(
          child: Product3dViewerScreen(
            productId: id,
            width: (extra?['width'] as double?) ?? 0,
            height: (extra?['height'] as double?) ?? 0,
            depth: (extra?['depth'] as double?) ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: AppPaths.modelingMethod,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: ModelingMethodScreen()),
    ),
    GoRoute(
      path: AppPaths.modelingCameraSingle,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: ModelingCameraSingleScreen()),
    ),
    GoRoute(
      path: AppPaths.modelingCameraMulti,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: ModelingCameraMultiScreen()),
    ),
    GoRoute(
      path: AppPaths.modelingCreateAlbum,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: ModelingCreateAlbumScreen()),
    ),
    GoRoute(
      path: AppPaths.modelingCreateSingle,
      builder: (context, state) {
        final file = state.extra! as XFile;
        return _BackToHomeOnRootPop(
          child: ModelingCreateSingleScreen(file: file),
        );
      },
    ),
    GoRoute(
      path: AppPaths.productSearch,
      pageBuilder:
          (context, state) => const NoTransitionPage(
            child: _BackToHomeOnRootPop(child: ProductSearchScreen()),
          ),
    ),
    GoRoute(
      path: AppPaths.productSearchResult,
      pageBuilder: (context, state) {
        final keyword = state.extra! as String;
        return NoTransitionPage(
          child: _BackToHomeOnRootPop(
            child: ProductSearchResultScreen(keyword: keyword),
          ),
        );
      },
    ),
    GoRoute(
      path: AppPaths.myProducts,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: MyProductsScreen()),
    ),
    GoRoute(
      path: AppPaths.recommendCategory,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: RecommendCategoryScreen()),
    ),
    GoRoute(
      path: AppPaths.recommendResult,
      builder:
          (context, state) =>
              const _BackToHomeOnRootPop(child: RecommendResultScreen()),
    ),
    GoRoute(
      path: AppPaths.sellerProfile,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final extra = state.extra! as Map<String, dynamic>;
        return _BackToHomeOnRootPop(
          child: SellerProfileScreen(
            userId: userId,
            nickname: extra['nickname'] as String,
            userImageUrl: extra['userImageUrl'] as String?,
          ),
        );
      },
    ),
    GoRoute(
      path: AppPaths.login,
      builder:
          (context, state) => const _BackToHomeOnRootPop(child: LoginScreen()),
    ),
    GoRoute(
      path: AppPaths.signup,
      builder:
          (context, state) => const _BackToHomeOnRootPop(child: SignupScreen()),
    ),
  ],
);

class _BackToHomeOnRootPop extends StatelessWidget {
  const _BackToHomeOnRootPop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || canPop) return;

        if (GoRouterState.of(context).uri.path != AppPaths.home) {
          context.go(AppPaths.home);
        }
      },
      child: child,
    );
  }
}

class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _myTabIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          if (index == _myTabIndex) {
            final isLoggedIn = ref.read(isLoggedInProvider);
            if (!isLoggedIn) {
              context.push(AppPaths.login);
              return;
            }
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
