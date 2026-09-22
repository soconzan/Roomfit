import 'package:roomfit_client/features/product/domain/entities/product_page.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class FetchMyProductsUseCase {
  const FetchMyProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductPage> call({int? cursor}) =>
      _repository.fetchMyProducts(cursor: cursor);
}
