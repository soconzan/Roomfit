import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:roomfit_client/core/constants/app_api.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _currentToken;
  static Dio? _serverDio;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  static void attachServerClient(Dio dio) {
    _serverDio = dio;
  }

  static Future<void> initializeFcm() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await _getToken();
        _currentToken = fcmToken;

        debugPrint('🟢 [INFO] FCM 토큰 수신: ${_maskToken(fcmToken)}');

        await _tokenRefreshSubscription?.cancel();
        _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
          newToken,
        ) async {
          _currentToken = newToken;
          debugPrint('🟢 [INFO] FCM 토큰 갱신: $newToken');
          await registerToken();
        });

        await _messageSubscription?.cancel();
        _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
          debugPrint(
            '🟢 [INFO] 포그라운드 FCM 수신: title=${message.notification?.title}, body=${message.notification?.body}',
          );
        });

        await _messageOpenedSubscription?.cancel();
        _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
          message,
        ) {
          debugPrint(
            '🟢 [INFO] 알림 탭으로 앱 열림: title=${message.notification?.title}, body=${message.notification?.body}',
          );
        });
      } else {
        debugPrint(
          '🟡 [WARN] FCM 권한이 허용되지 않음: ${settings.authorizationStatus}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 [ERROR] FCM 초기화 실패: $e');
      debugPrint(stackTrace.toString());
    }
  }

  static Future<void> registerToken([Dio? dio]) async {
    final client = dio ?? _serverDio;
    if (client == null) {
      debugPrint('🟡 [WARN] FCM 서버용 Dio가 없어 토큰 등록을 건너뜀');
      return;
    }

    final token = _currentToken ?? await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('🟡 [WARN] FCM 토큰이 없어 서버 등록을 건너뜀');
      return;
    }

    try {
      await client.post<void>(AppApi.fcmToken, data: {'fcmToken': token});
      debugPrint('🟢 [INFO] FCM 토큰 서버 등록 완료');
    } catch (e, stackTrace) {
      debugPrint('🔴 [ERROR] FCM 토큰 서버 등록 실패: $e');
      debugPrint(stackTrace.toString());
    }
  }

  static Future<void> unregisterToken([Dio? dio]) async {
    final client = dio ?? _serverDio;
    if (client == null) {
      debugPrint('🟡 [WARN] FCM 서버용 Dio가 없어 토큰 삭제를 건너뜀');
      return;
    }

    final token = _currentToken ?? await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('🟡 [WARN] FCM 토큰이 없어 서버 삭제를 건너뜀');
      return;
    }

    try {
      await client.delete<void>(AppApi.fcmToken, data: {'fcmToken': token});
      debugPrint('🟢 [INFO] FCM 토큰 서버 삭제 완료');
    } catch (e, stackTrace) {
      debugPrint('🔴 [ERROR] FCM 토큰 서버 삭제 실패: $e');
      debugPrint(stackTrace.toString());
    }
  }

  static Future<String?> _getToken() {
    if (kIsWeb) {
      return _messaging.getToken(
        vapidKey:
            'BBodMmnupQ8BHii3JwOmKNa1s4ZZZ3XXYYn9xTDD4MBC6ZS33rKHeBvIYQYFhNtRHpO751qKCg9Q0yZ7ECBkw4g',
      );
    }

    return _messaging.getToken();
  }

  static String _maskToken(String? token) {
    if (token == null || token.isEmpty) {
      return 'null';
    }

    if (token.length <= 12) {
      return '***';
    }

    final prefix = token.substring(0, 6);
    final suffix = token.substring(token.length - 4);
    return '$prefix...$suffix';
  }
}
