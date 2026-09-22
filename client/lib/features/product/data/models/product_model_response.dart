import 'package:roomfit_client/features/product/domain/entities/product_model.dart';

class ProductModelResponse {
  const ProductModelResponse({required this.productId, required this.modelUrl});

  final int productId;
  final String modelUrl;

  factory ProductModelResponse.fromJson(Map<String, dynamic> json) =>
      ProductModelResponse(
        productId: json['productId'] as int,
        modelUrl: json['modelUrl'] as String,
      );

  ProductModel toEntity() => ProductModel(productId: productId, modelUrl: modelUrl);
}