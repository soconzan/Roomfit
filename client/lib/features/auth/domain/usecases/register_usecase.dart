import 'package:roomfit_client/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String username, String password, String name) =>
      _repository.register(username, password, name);
}
