class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
}

class CheckResult {
  const CheckResult({required this.success, required this.message});

  final bool success;
  final String message;
}
