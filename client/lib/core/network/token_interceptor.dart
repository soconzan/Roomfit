import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomfit_client/core/constants/app_api.dart';

// auth_provider가 구독해서 로그아웃 + 화면 이동을 처리함
final _sessionExpiredController = StreamController<void>.broadcast();
Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

class TokenInterceptor extends QueuedInterceptor {
  TokenInterceptor({required this.storage, required this.dio});

  final FlutterSecureStorage storage;
  final Dio dio;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _retryKey = '_token_retry';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: _accessKey);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final isUnauthorized = status == 401 || status == 403;
    final isRetry = err.requestOptions.extra[_retryKey] == true;
    final isRefreshEndpoint =
        err.requestOptions.path.contains(AppApi.authRefresh);

    debugPrint('[token] onError → status: ${err.response?.statusCode}, path: ${err.requestOptions.path}');

    if (isUnauthorized && !isRetry && !isRefreshEndpoint) {
      final refreshToken = await storage.read(key: _refreshKey);
      if (refreshToken != null) {
        try {
          debugPrint('[token] 재발급 요청 → POST ${AppApi.baseUrl}${AppApi.authRefresh}');
          debugPrint('[token] 요청 body: {refreshToken: ${refreshToken.substring(0, refreshToken.length.clamp(0, 20))}...}');

          // 별도 Dio 인스턴스로 순환 방지
          final tempDio = Dio(BaseOptions(baseUrl: AppApi.baseUrl));
          final res = await tempDio.post<Map<String, dynamic>>(
            AppApi.authRefresh,
            data: {'refreshToken': refreshToken},
          );

          debugPrint('[token] 재발급 응답 status: ${res.statusCode}');
          debugPrint('[token] 재발급 응답 body (raw): ${res.data}');
          debugPrint('[token] 재발급 응답 headers: ${res.headers}');

          final data = res.data!['data'] as Map<String, dynamic>;
          final newToken = data['newAccessToken'] as String;
          final newRefreshToken = data['newRefreshToken'] as String;
          debugPrint('[token] 새 accessToken 저장 완료 (${newToken.substring(0, newToken.length.clamp(0, 20))}...)');
          debugPrint('[token] 새 refreshToken 저장 완료 (${newRefreshToken.substring(0, newRefreshToken.length.clamp(0, 20))}...)');
          await storage.write(key: _accessKey, value: newToken);
          await storage.write(key: _refreshKey, value: newRefreshToken);

          // 원래 요청 재시도
          final opts = err.requestOptions.copyWith(
            extra: {...err.requestOptions.extra, _retryKey: true},
          );
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(opts);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          debugPrint('[token] 재발급 실패: $e');
        }
      }
      // refresh 실패 → 세션 만료 처리
      debugPrint('[token] 세션 만료 처리 시작');
      await _handleSessionExpired();
    }

    handler.next(err);
  }

  Future<void> _handleSessionExpired() async {
    await storage.delete(key: _accessKey);
    await storage.delete(key: _refreshKey);
    _sessionExpiredController.add(null);
  }
}
