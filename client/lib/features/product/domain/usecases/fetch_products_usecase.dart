import 'package:roomfit_client/features/product/domain/entities/product_page.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class FetchProductsUseCase {
  const FetchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductPage> call({int? cursor, int? categoryId}) =>
      _repository.fetchProducts(cursor: cursor, categoryId: categoryId);
}
