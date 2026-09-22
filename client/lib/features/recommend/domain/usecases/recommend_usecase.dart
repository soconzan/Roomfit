import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';
import 'package:roomfit_client/features/recommend/domain/repositories/recommend_repository.dart';

class RecommendUseCase {
  const RecommendUseCase(this._repository);
  final RecommendRepository _repository;

  Future<List<RecommendResult>> call(RecommendRequestParams params) =>
      _repository.recommend(params);
}
