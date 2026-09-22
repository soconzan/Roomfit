import 'package:roomfit_client/features/product/domain/entities/product_model.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class FetchProductModelUseCase {
  const FetchProductModelUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductModel> call(int id) => _repository.fetchProductModel(id);
}