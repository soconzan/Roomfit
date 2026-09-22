import 'package:roomfit_client/features/product/domain/entities/update_product_params.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(UpdateProductParams params) =>
      _repository.updateProduct(params);
}
