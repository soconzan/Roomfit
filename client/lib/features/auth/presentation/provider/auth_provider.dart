import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/network/dio_client.dart';
import 'package:roomfit_client/core/network/token_interceptor.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:roomfit_client/features/auth/data/sources/remote/auth_remote_source.dart';
import 'package:roomfit_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:roomfit_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:roomfit_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:roomfit_client/main.dart';
import 'package:roomfit_client/service/fcm_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthRemoteSource(ref.watch(dioProvider))),
);

final _loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final _registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends AsyncNotifier<String?> {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  @override
  Future<String?> build() async {
    // 세션 만료 스트림 구독 — 로그아웃 처리 및 안내 메시지 표시
    final sub = sessionExpiredStream.listen((_) async {
      await logout();
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('로그인이 만료되었습니다. 다시 로그인해주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
      appRouter.go(AppPaths.login);
    });
    ref.onDispose(sub.cancel);

    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: _accessTokenKey);
    debugPrint(
      '[auth] 저장된 accessToken: ${token != null ? '있음 (${token.substring(0, token.length.clamp(0, 20))}...)' : '없음'}',
    );
    return token;
  }

  Future<void> login(String username, String password) async {
    final tokens = await ref
        .read(_loginUseCaseProvider)
        .call(username, password);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await storage.write(key: _userIdKey, value: tokens.userId);
    state = AsyncData(tokens.accessToken);

    final dio = ref.read(dioProvider);
    FcmService.attachServerClient(dio);
    await FcmService.registerToken(dio);
  }

  Future<void> register(String username, String password, String name) async {
    await ref.read(_registerUseCaseProvider).call(username, password, name);
  }

  Future<void> logout() async {
    await FcmService.unregisterToken(ref.read(dioProvider));

    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _userIdKey);
    state = const AsyncData(null);
  }

  Future<String?> getUserId() =>
      ref.read(secureStorageProvider).read(key: _userIdKey);

  Future<String?> getRefreshToken() =>
      ref.read(secureStorageProvider).read(key: _refreshTokenKey);
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(
  AuthNotifier.new,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).valueOrNull != null,
);

final currentUserIdProvider = FutureProvider<String?>((ref) {
  ref.watch(authProvider); // 로그인/로그아웃 시 재조회
  return ref.read(authProvider.notifier).getUserId();
});
