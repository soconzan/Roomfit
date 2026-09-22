import 'package:roomfit_client/features/auth/domain/entities/auth_tokens.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> login(String username, String password);
  Future<void> register(String username, String password, String name);
  Future<CheckResult> checkId(String username);
  Future<CheckResult> checkName(String name);
}
