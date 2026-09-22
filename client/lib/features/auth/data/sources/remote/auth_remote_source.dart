import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/features/auth/data/models/auth_token_response.dart';
import 'package:roomfit_client/features/auth/data/models/check_result_response.dart';
import 'package:roomfit_client/features/auth/data/models/login_request.dart';
import 'package:roomfit_client/features/auth/data/models/register_request.dart';
import 'package:roomfit_client/features/auth/domain/entities/auth_tokens.dart';

class AuthRemoteSource {
  const AuthRemoteSource(this._dio);

  final Dio _dio;

  Future<AuthTokens> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AppApi.authLogin,
      data: LoginRequest(username: username, password: password).toJson(),
    );
    final body = response.data!;
    debugPrint('[login] response body: $body');
    final data = body['data'] as Map<String, dynamic>;
    return AuthTokenResponse.fromJson(data).toEntity();
  }

  Future<void> register(
    String username,
    String password,
    String nickname,
  ) async {
    await _dio.post<void>(
      AppApi.authRegister,
      data:
          RegisterRequest(
            username: username,
            nickname: nickname,
            password: password,
          ).toJson(),
    );
  }

  Future<CheckResult> checkId(String username) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.authCheckId,
      queryParameters: {'username': username},
    );
    final data = response.data!;
    debugPrint('[checkId] raw response: $data');
    return CheckResultResponse.fromJson(data).toEntity();
  }

  Future<CheckResult> checkName(String name) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.authCheckName,
      queryParameters: {'name': name},
    );
    final data = response.data!;
    debugPrint('[checkName] raw response: $data');
    return CheckResultResponse.fromJson(data).toEntity();
  }
}
