import 'package:roomfit_client/features/product/domain/entities/product.dart';

class ProductListItemResponse {
  const ProductListItemResponse({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.categoryName,
    required this.createdAt,
    required this.thumbnailUrl,
  });

  factory ProductListItemResponse.fromJson(Map<String, dynamic> json) =>
      ProductListItemResponse(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        productPrice: json['productPrice'] as int,
        categoryName: json['categoryName'] as String,
        createdAt: json['createdAt'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
      );

  final int productId;
  final String productName;
  final int productPrice;
  final String categoryName;
  final String createdAt;
  final String thumbnailUrl;

  Product toEntity() => Product(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        categoryName: categoryName,
        createdAt: createdAt,
        thumbnailUrl: thumbnailUrl,
      );
}
