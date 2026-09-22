import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/network/dio_client.dart';
import 'package:roomfit_client/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:roomfit_client/features/profile/data/sources/remote/profile_remote_source.dart';
import 'package:roomfit_client/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ProfileRemoteSource(ref.watch(dioProvider))),
);
