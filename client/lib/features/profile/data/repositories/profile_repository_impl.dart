import 'package:roomfit_client/features/profile/data/sources/remote/profile_remote_source.dart';
import 'package:roomfit_client/features/profile/domain/entities/user_profile.dart';
import 'package:roomfit_client/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._source);

  final ProfileRemoteSource _source;

  @override
  Future<UserProfile> getProfile() async {
    final response = await _source.getProfile();
    return response.toEntity();
  }
}
