import 'package:roomfit_client/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getProfile();
}
