import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/features/recommend/data/models/recommend_result_response.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';

class RecommendRemoteSource {
  const RecommendRemoteSource(this._dio);
  final Dio _dio;

  Future<List<RecommendResult>> recommend(RecommendRequestParams params) async {
    final imageBytes = await params.image.readAsBytes();
    final formData = FormData.fromMap({
      if (params.categoryId != null) 'category': params.categoryId,
      'image': MultipartFile.fromBytes(imageBytes, filename: params.image.name),
      'width': params.width,
      'height': params.height,
      'depth': params.depth,
    });

    debugPrint('🟢 [INFO] recommend 요청:');
    debugPrint('  categoryId=${params.categoryId}');
    debugPrint(
      '  width=${params.width}, height=${params.height}, depth=${params.depth}',
    );

    final response = await _dio.post<dynamic>(AppApi.recommend, data: formData);

    final raw = response.data;
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic> && raw['data'] is List) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }

    debugPrint('🟢 [INFO] recommend 응답: ${list.length}개');

    return list
        .map(
          (e) => RecommendResultResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
