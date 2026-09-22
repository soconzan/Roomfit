import 'package:roomfit_client/features/recommend/data/sources/remote/recommend_remote_source.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';
import 'package:roomfit_client/features/recommend/domain/repositories/recommend_repository.dart';

class RecommendRepositoryImpl implements RecommendRepository {
  const RecommendRepositoryImpl(this._source);
  final RecommendRemoteSource _source;

  @override
  Future<List<RecommendResult>> recommend(RecommendRequestParams params) =>
      _source.recommend(params);
}
