import 'package:roomfit_client/features/auth/domain/entities/auth_tokens.dart';
import 'package:roomfit_client/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call(String username, String password) =>
      _repository.login(username, password);
}
