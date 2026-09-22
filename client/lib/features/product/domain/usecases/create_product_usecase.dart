import 'package:roomfit_client/features/product/domain/entities/create_product_params.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  const CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(CreateProductParams params) =>
      _repository.createProduct(params);
}
