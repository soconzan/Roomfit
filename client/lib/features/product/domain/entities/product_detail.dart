import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_detail.freezed.dart';

@freezed
class ProductDetail with _$ProductDetail {
  const factory ProductDetail({
    required int productId,
    required String userId,
    required String nickname,
    required String productName,
    required int categoryId,
    required String categoryName,
    required int productPrice,
    required String description,
    required double productWidth,
    required double productDepth,
    required double productHeight,
    required String productMaterial,
    required String createdAt,
    required String? updatedAt,
    required List<String> imageUrls,
    required String? userImageUrl,
  }) = _ProductDetail;
}
