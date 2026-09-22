import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(int id) => _repository.deleteProduct(id);
}
