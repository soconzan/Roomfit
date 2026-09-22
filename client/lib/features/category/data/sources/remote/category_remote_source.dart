import 'package:dio/dio.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/features/category/data/models/category_response.dart';

class CategoryRemoteSource {
  const CategoryRemoteSource(this._dio);

  final Dio _dio;

  Future<List<CategoryResponse>> fetchCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(AppApi.categories);
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => CategoryResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
