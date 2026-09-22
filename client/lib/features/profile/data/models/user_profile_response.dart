import 'package:roomfit_client/features/profile/domain/entities/user_profile.dart';

class UserProfileResponse {
  const UserProfileResponse({
    required this.username,
    required this.nickname,
    this.imageUrl,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        username: json['username'] as String,
        nickname: json['nickname'] as String,
        imageUrl: json['imageUrl'] as String?,
      );

  final String username;
  final String nickname;
  final String? imageUrl;

  UserProfile toEntity() =>
      UserProfile(username: username, nickname: nickname, imageUrl: imageUrl);
}
