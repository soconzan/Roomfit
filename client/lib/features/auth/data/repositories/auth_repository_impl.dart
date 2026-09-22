import 'package:roomfit_client/features/auth/data/sources/remote/auth_remote_source.dart';
import 'package:roomfit_client/features/auth/domain/entities/auth_tokens.dart';
import 'package:roomfit_client/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._source);

  final AuthRemoteSource _source;

  @override
  Future<AuthTokens> login(String username, String password) =>
      _source.login(username, password);

  @override
  Future<void> register(String username, String password, String name) =>
      _source.register(username, password, name);

  @override
  Future<CheckResult> checkId(String username) => _source.checkId(username);

  @override
  Future<CheckResult> checkName(String name) => _source.checkName(name);
}
