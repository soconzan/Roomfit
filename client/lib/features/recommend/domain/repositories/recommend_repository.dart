import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';

abstract class RecommendRepository {
  Future<List<RecommendResult>> recommend(RecommendRequestParams params);
}
