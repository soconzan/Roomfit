import 'package:image_picker/image_picker.dart';
import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';

class CreateProductParams {
  const CreateProductParams({
    required this.userId,
    required this.productName,
    required this.productPrice,
    required this.categoryId,
    required this.description,
    required this.productWidth,
    required this.productDepth,
    required this.productHeight,
    required this.productMaterial,
    required this.images,
    required this.modelImages,
  });

  final String userId;
  final String productName;
  final int productPrice;
  final int categoryId;
  final String description;
  final double productWidth;
  final double productDepth;
  final double productHeight;
  final String productMaterial;
  final List<XFile> images;
  final List<LabeledPhoto> modelImages;
}
