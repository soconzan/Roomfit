import 'package:dio/dio.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/features/profile/data/models/user_profile_response.dart';

class ProfileRemoteSource {
  const ProfileRemoteSource(this._dio);

  final Dio _dio;

  Future<UserProfileResponse> getProfile() async {
    final response =
        await _dio.get<Map<String, dynamic>>(AppApi.userMe);
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserProfileResponse.fromJson(data);
  }
}
