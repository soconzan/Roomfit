import 'package:roomfit_client/features/product/domain/entities/product_page.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductPage> call({String? keyword, int? cursor}) =>
      _repository.searchProducts(keyword: keyword, cursor: cursor);
}
