import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';

class ProductDetailResponse {
  const ProductDetailResponse({
    required this.productId,
    required this.userId,
    required this.nickname,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.productPrice,
    required this.description,
    required this.productWidth,
    required this.productDepth,
    required this.productHeight,
    required this.productMaterial,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrls,
    required this.userImageUrl,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) =>
      ProductDetailResponse(
        productId: json['productId'] as int,
        userId: json['userId'] as String,
        nickname: json['nickname'] as String,
        productName: json['productName'] as String,
        categoryId: json['categoryId'] as int,
        categoryName: json['categoryName'] as String,
        productPrice: json['productPrice'] as int,
        description: json['description'] as String,
        productWidth: (json['productWidth'] as num).toDouble(),
        productDepth: (json['productDepth'] as num).toDouble(),
        productHeight: (json['productHeight'] as num).toDouble(),
        productMaterial: json['material'] as String? ?? '',
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String?,
        imageUrls:
            (json['imageUrls'] as List<dynamic>)
                .map((e) => e as String)
                .toList(),
        userImageUrl: json['userImagUrl'] as String?,
      );

  final int productId;
  final String userId;
  final String nickname;
  final String productName;
  final int categoryId;
  final String categoryName;
  final int productPrice;
  final String description;
  final double productWidth;
  final double productDepth;
  final double productHeight;
  final String productMaterial;
  final String createdAt;
  final String? updatedAt;
  final List<String> imageUrls;
  final String? userImageUrl;

  ProductDetail toEntity() => ProductDetail(
    productId: productId,
    userId: userId,
    nickname: nickname,
    productName: productName,
    categoryId: categoryId,
    categoryName: categoryName,
    productPrice: productPrice,
    description: description,
    productWidth: productWidth,
    productDepth: productDepth,
    productHeight: productHeight,
    productMaterial: productMaterial,
    createdAt: createdAt,
    updatedAt: updatedAt,
    imageUrls: imageUrls,
    userImageUrl: userImageUrl,
  );
}
