import 'package:image_picker/image_picker.dart';

class RecommendRequestParams {
  const RecommendRequestParams({
    required this.image,
    required this.width,
    required this.height,
    required this.depth,
    this.categoryId,
  });

  final XFile image;
  final double width;
  final double height;
  final double depth;
  final int? categoryId;
}
