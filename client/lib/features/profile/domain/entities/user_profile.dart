class UserProfile {
  const UserProfile({
    required this.username,
    required this.nickname,
    this.imageUrl,
  });

  final String username;
  final String nickname;
  final String? imageUrl;
}
