import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/domain/repositories/category_repository.dart';

class FetchCategoriesUseCase {
  const FetchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call() => _repository.fetchCategories();
}
