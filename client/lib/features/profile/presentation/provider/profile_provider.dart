import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/profile/data/repositories/profile_repository_provider.dart';
import 'package:roomfit_client/features/profile/domain/entities/user_profile.dart';
import 'package:roomfit_client/features/profile/domain/usecases/get_profile_usecase.dart';

final _getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)),
);

// authProvider를 watch해서 로그인/로그아웃 시 자동 재조회
final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  final token = ref.watch(authProvider).valueOrNull;
  if (token == null) throw Exception('로그인이 필요합니다.');
  return ref.read(_getProfileUseCaseProvider).call();
});
