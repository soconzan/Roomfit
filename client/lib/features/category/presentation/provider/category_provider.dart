import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/features/category/data/repositories/category_repository_provider.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/domain/usecases/fetch_categories_usecase.dart';

final _fetchCategoriesUseCaseProvider = Provider<FetchCategoriesUseCase>(
  (ref) => FetchCategoriesUseCase(ref.watch(categoryRepositoryProvider)),
);

// autoDispose 없이 선언 → 앱 실행 중 메모리에 유지되어 1회만 API 호출
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(_fetchCategoriesUseCaseProvider).call();
});
