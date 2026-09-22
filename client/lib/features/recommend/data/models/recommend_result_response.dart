import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';

class RecommendResultResponse {
  const RecommendResultResponse({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productWidth,
    required this.productDepth,
    required this.productHeight,
    required this.imageUrl,
    required this.modelUrl,
  });

  final int productId;
  final String productName;
  final int productPrice;
  final double productWidth;
  final double productDepth;
  final double productHeight;
  final String imageUrl;
  final String modelUrl;

  factory RecommendResultResponse.fromJson(Map<String, dynamic> json) =>
      RecommendResultResponse(
        productId: (json['productId'] as num).toInt(),
        productName: json['productName'] as String? ?? '',
        productPrice: (json['productPrice'] as num?)?.toInt() ?? 0,
        productWidth: (json['productWidth'] as num?)?.toDouble() ?? 0,
        productDepth: (json['productDepth'] as num?)?.toDouble() ?? 0,
        productHeight: (json['productHeight'] as num?)?.toDouble() ?? 0,
        imageUrl: json['imageUrl'] as String? ?? '',
        modelUrl: json['modelUrl'] as String? ?? '',
      );

  RecommendResult toEntity() => RecommendResult(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        productWidth: productWidth,
        productDepth: productDepth,
        productHeight: productHeight,
        imageUrl: imageUrl,
        modelUrl: modelUrl,
      );
}
