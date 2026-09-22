import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';

class UpdateProductParams {
  const UpdateProductParams({
    required this.productId,
    required this.userId,
    required this.productName,
    required this.productPrice,
    required this.categoryId,
    required this.description,
    required this.productWidth,
    required this.productDepth,
    required this.productHeight,
    required this.productMaterial,
    this.modelImages,
  });

  final int productId;
  final String userId;
  final String productName;
  final int productPrice;
  final int categoryId;
  final String description;
  final double productWidth;
  final double productDepth;
  final double productHeight;
  final String productMaterial;
  /// null이면 3D 모델 재생성 요청 없음
  final List<LabeledPhoto>? modelImages;
}
