import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/features/product/data/models/product_detail_response.dart';
import 'package:roomfit_client/features/product/data/models/product_model_response.dart';
import 'package:roomfit_client/features/product/data/models/product_page_response.dart';
import 'package:roomfit_client/features/product/domain/entities/create_product_params.dart';
import 'package:roomfit_client/features/product/domain/entities/update_product_params.dart';

class ProductRemoteSource {
  const ProductRemoteSource(this._dio);

  final Dio _dio;

  Future<ProductPageResponse> fetchProducts({
    int? cursor,
    int? categoryId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.products,
      queryParameters: {
        if (cursor != null) 'lastFetchedId': cursor,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductPageResponse.fromJson(data);
  }

  Future<ProductDetailResponse> fetchProductDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.productDetail(id),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductDetailResponse.fromJson(data);
  }

  Future<ProductModelResponse> fetchProductModel(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.productModel(id),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductModelResponse.fromJson(data);
  }

  Future<ProductPageResponse> fetchMyProducts({int? cursor}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.myProducts,
      queryParameters: {if (cursor != null) 'lastFetchedId': cursor},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductPageResponse.fromJson(data);
  }

  Future<ProductPageResponse> searchProducts({
    String? keyword,
    int? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      AppApi.productSearch,
      queryParameters: {
        if (keyword != null) 'keyword': keyword,
        if (cursor != null) 'lastFetchedId': cursor,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductPageResponse.fromJson(data);
  }

  Future<void> deleteProduct(int id) async {
    debugPrint(
      '🟢 [INFO] deleteProduct 요청: id=$id, url=${AppApi.productDetail(id)}',
    );
    try {
      final response = await _dio.delete<dynamic>(AppApi.productDetail(id));
      debugPrint(
        '🟢 [INFO] deleteProduct 응답: statusCode=${response.statusCode}, data=${response.data}',
      );
    } catch (e, st) {
      debugPrint('🔴 [ERROR] deleteProduct 실패: $e');
      debugPrint('🔴 [ERROR] $st');
      rethrow;
    }
  }

  Future<void> createProduct(CreateProductParams params) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('userId', params.userId),
      MapEntry('productName', params.productName),
      MapEntry('productPrice', params.productPrice.toString()),
      MapEntry('categoryId', params.categoryId.toString()),
      MapEntry('description', params.description),
      MapEntry('productWidth', params.productWidth.toString()),
      MapEntry('productDepth', params.productDepth.toString()),
      MapEntry('productHeight', params.productHeight.toString()),
      MapEntry('productMaterial', params.productMaterial),
    ]);

    for (final image in params.images) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(image.path, filename: image.name),
        ),
      );
    }

    // LabeledPhoto.label 값('front', 'left', 'right', 'back')을
    // 백엔드 필드명(frontImage, leftImage, rightImage, backImage)으로 매핑
    for (final photo in params.modelImages) {
      formData.files.add(
        MapEntry(
          '${photo.label}Image',
          await MultipartFile.fromFile(
            photo.file.path,
            filename: photo.file.name,
          ),
        ),
      );
    }

    await _dio.post<void>(AppApi.createProduct, data: formData);
  }

  Future<void> updateProduct(UpdateProductParams params) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('userId', params.userId),
      MapEntry('productName', params.productName),
      MapEntry('productPrice', params.productPrice.toString()),
      MapEntry('categoryId', params.categoryId.toString()),
      MapEntry('description', params.description),
      MapEntry('productWidth', params.productWidth.toString()),
      MapEntry('productDepth', params.productDepth.toString()),
      MapEntry('productHeight', params.productHeight.toString()),
      MapEntry('productMaterial', params.productMaterial),
    ]);

    if (params.modelImages != null) {
      for (final photo in params.modelImages!) {
        formData.files.add(
          MapEntry(
            '${photo.label}Image',
            await MultipartFile.fromFile(
              photo.file.path,
              filename: photo.file.name,
            ),
          ),
        );
      }
    }

    debugPrint('🟢 [INFO] updateProduct 요청 필드:');
    debugPrint('  productId=${params.productId}');
    debugPrint('  userId=${params.userId}');
    debugPrint('  productName=${params.productName}');
    debugPrint('  productPrice=${params.productPrice}');
    debugPrint('  categoryId=${params.categoryId}');
    debugPrint('  description=${params.description}');
    debugPrint('  productWidth=${params.productWidth}');
    debugPrint('  productDepth=${params.productDepth}');
    debugPrint('  productHeight=${params.productHeight}');
    debugPrint('  productMaterial=${params.productMaterial}');
    debugPrint('  modelImages=${params.modelImages?.map((e) => '${e.label}=${e.file.name}').toList() ?? '없음'}');

    await _dio.patch<void>(
      AppApi.updateProduct(params.productId),
      data: formData,
    );
  }
}
