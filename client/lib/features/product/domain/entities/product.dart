import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int productId,
    required String productName,
    required int productPrice,
    required String categoryName,
    required String createdAt,
    required String thumbnailUrl,
  }) = _Product;
}
