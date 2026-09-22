class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.nickname,
    required this.password,
  });

  final String username;
  final String nickname;
  final String password;

  Map<String, dynamic> toJson() => {
    'username': username,
    'nickname': nickname,
    'password': password,
  };
}
