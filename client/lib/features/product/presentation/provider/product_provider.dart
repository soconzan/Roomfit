import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/product/data/repositories/product_repository_provider.dart';
import 'package:roomfit_client/features/product/domain/entities/product.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/domain/entities/product_model.dart';
import 'package:roomfit_client/features/product/domain/usecases/create_product_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/update_product_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/fetch_product_detail_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/fetch_product_model_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/fetch_products_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/fetch_my_products_usecase.dart';
import 'package:roomfit_client/features/product/domain/usecases/search_products_usecase.dart';

final _fetchProductsUseCaseProvider = Provider<FetchProductsUseCase>(
  (ref) => FetchProductsUseCase(ref.watch(productRepositoryProvider)),
);

final _fetchProductDetailUseCaseProvider = Provider<FetchProductDetailUseCase>(
  (ref) => FetchProductDetailUseCase(ref.watch(productRepositoryProvider)),
);

final _fetchProductModelUseCaseProvider = Provider<FetchProductModelUseCase>(
  (ref) => FetchProductModelUseCase(ref.watch(productRepositoryProvider)),
);

final createProductUseCaseProvider = Provider<CreateProductUseCase>(
  (ref) => CreateProductUseCase(ref.watch(productRepositoryProvider)),
);

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>(
  (ref) => UpdateProductUseCase(ref.watch(productRepositoryProvider)),
);

// 카테고리 탭(ProductScreen) 전용 — 첫 페이지만 조회
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final page = await ref.read(_fetchProductsUseCaseProvider).call();
  return page.products;
});

final productDetailProvider =
    FutureProvider.autoDispose.family<ProductDetail, int>((ref, id) {
  return ref.read(_fetchProductDetailUseCaseProvider).call(id);
});

final productModelProvider =
    FutureProvider.autoDispose.family<ProductModel, int>((ref, id) {
  return ref.read(_fetchProductModelUseCaseProvider).call(id);
});

// 홈 탭 전용 — 무한스크롤 지원
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  int? _nextCursor;
  bool _hasNext = true;
  bool _isLoadingMore = false;

  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Product>> build() async {
    debugPrint('🟢 [INFO] 상품 목록 초기 로드 시작');
    final page = await ref.read(_fetchProductsUseCaseProvider).call();
    _nextCursor = page.nextCursor;
    _hasNext = page.hasNext;
    debugPrint('🟢 [INFO] 상품 목록 초기 로드 완료: ${page.products.length}개, nextCursor=$_nextCursor, hasNext=$_hasNext');
    return page.products;
  }

  Future<void> loadMore() async {
    if (!_hasNext || _isLoadingMore) return;
    _isLoadingMore = true;
    debugPrint('🟢 [INFO] 상품 추가 로드 시작 (cursor=$_nextCursor)');
    try {
      final current = state.valueOrNull ?? [];
      final page = await ref
          .read(_fetchProductsUseCaseProvider)
          .call(cursor: _nextCursor);
      _nextCursor = page.nextCursor;
      _hasNext = page.hasNext;
      state = AsyncData([...current, ...page.products]);
      debugPrint('🟢 [INFO] 상품 추가 로드 완료: +${page.products.length}개 (누적 ${current.length + page.products.length}개), nextCursor=$_nextCursor, hasNext=$_hasNext');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _nextCursor = null;
    _hasNext = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }
}

final productsNotifierProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

// 검색 전용
final _searchProductsUseCaseProvider = Provider<SearchProductsUseCase>(
  (ref) => SearchProductsUseCase(ref.watch(productRepositoryProvider)),
);

class SearchProductsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Product>, String> {
  int? _nextCursor;
  bool _hasNext = true;
  bool _isLoadingMore = false;

  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Product>> build(String keyword) async {
    _nextCursor = null;
    _hasNext = true;
    _isLoadingMore = false;
    debugPrint('🟢 [INFO] 검색 시작: "$keyword"');
    final page = await ref
        .read(_searchProductsUseCaseProvider)
        .call(keyword: keyword);
    _nextCursor = page.nextCursor;
    _hasNext = page.hasNext;
    debugPrint('🟢 [INFO] 검색 완료: ${page.products.length}개');
    return page.products;
  }

  Future<void> loadMore() async {
    if (!_hasNext || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final current = state.valueOrNull ?? [];
      final page = await ref
          .read(_searchProductsUseCaseProvider)
          .call(keyword: arg, cursor: _nextCursor);
      _nextCursor = page.nextCursor;
      _hasNext = page.hasNext;
      state = AsyncData([...current, ...page.products]);
      debugPrint('🟢 [INFO] 검색 추가 로드 완료: +${page.products.length}개');
    } finally {
      _isLoadingMore = false;
    }
  }
}

final searchProductsProvider = AsyncNotifierProvider.autoDispose
    .family<SearchProductsNotifier, List<Product>, String>(
  SearchProductsNotifier.new,
);

// 카테고리별 상품 목록 (null = 전체)
class CategoryProductsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Product>, int?> {
  int? _nextCursor;
  bool _hasNext = true;
  bool _isLoadingMore = false;

  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Product>> build(int? categoryId) async {
    _nextCursor = null;
    _hasNext = true;
    _isLoadingMore = false;
    debugPrint('🟢 [INFO] 카테고리 상품 로드: categoryId=$categoryId');
    final page = await ref
        .read(_fetchProductsUseCaseProvider)
        .call(categoryId: categoryId);
    _nextCursor = page.nextCursor;
    _hasNext = page.hasNext;
    return page.products;
  }

  Future<void> loadMore() async {
    if (!_hasNext || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final current = state.valueOrNull ?? [];
      final page = await ref
          .read(_fetchProductsUseCaseProvider)
          .call(categoryId: arg, cursor: _nextCursor);
      _nextCursor = page.nextCursor;
      _hasNext = page.hasNext;
      state = AsyncData([...current, ...page.products]);
    } finally {
      _isLoadingMore = false;
    }
  }
}

final categoryProductsProvider = AsyncNotifierProvider.autoDispose
    .family<CategoryProductsNotifier, List<Product>, int?>(
  CategoryProductsNotifier.new,
);

// 내 상품 목록
final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>(
  (ref) => DeleteProductUseCase(ref.watch(productRepositoryProvider)),
);

final _fetchMyProductsUseCaseProvider = Provider<FetchMyProductsUseCase>(
  (ref) => FetchMyProductsUseCase(ref.watch(productRepositoryProvider)),
);

// 프로필 화면 미리보기용 — 첫 페이지만, auth 변경 시 자동 재조회
final myProductsPreviewProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final token = ref.watch(authProvider).valueOrNull;
  if (token == null) return [];
  final page = await ref.read(_fetchMyProductsUseCaseProvider).call();
  return page.products;
});

// 전체 목록 화면용 — 무한스크롤 지원
class MyProductsNotifier extends AsyncNotifier<List<Product>> {
  int? _nextCursor;
  bool _hasNext = true;
  bool _isLoadingMore = false;

  bool get hasNext => _hasNext;

  @override
  Future<List<Product>> build() async {
    // auth 변경(로그인/로그아웃) 시 자동 재조회
    ref.watch(authProvider);
    _nextCursor = null;
    _hasNext = true;
    _isLoadingMore = false;
    final page = await ref.read(_fetchMyProductsUseCaseProvider).call();
    _nextCursor = page.nextCursor;
    _hasNext = page.hasNext;
    return page.products;
  }

  Future<void> loadMore() async {
    if (!_hasNext || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final current = state.valueOrNull ?? [];
      final page = await ref
          .read(_fetchMyProductsUseCaseProvider)
          .call(cursor: _nextCursor);
      _nextCursor = page.nextCursor;
      _hasNext = page.hasNext;
      state = AsyncData([...current, ...page.products]);
    } finally {
      _isLoadingMore = false;
    }
  }
}

final myProductsProvider =
    AsyncNotifierProvider<MyProductsNotifier, List<Product>>(
  MyProductsNotifier.new,
);
