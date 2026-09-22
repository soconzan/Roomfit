import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class FetchProductDetailUseCase {
  const FetchProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductDetail> call(int id) => _repository.fetchProductDetail(id);
}
