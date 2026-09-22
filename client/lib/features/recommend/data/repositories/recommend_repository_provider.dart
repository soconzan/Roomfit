import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/network/dio_client.dart';
import 'package:roomfit_client/features/recommend/data/repositories/recommend_repository_impl.dart';
import 'package:roomfit_client/features/recommend/data/sources/remote/recommend_remote_source.dart';
import 'package:roomfit_client/features/recommend/domain/repositories/recommend_repository.dart';

final recommendRepositoryProvider = Provider<RecommendRepository>(
  (ref) => RecommendRepositoryImpl(
    RecommendRemoteSource(ref.watch(dioProvider)),
  ),
);
