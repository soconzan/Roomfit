import 'package:roomfit_client/features/category/domain/entities/category.dart';

class CategoryResponse {
  const CategoryResponse({required this.categoryId, required this.categoryName});

  final int categoryId;
  final String categoryName;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        categoryId: json['categoryId'] as int,
        categoryName: json['categoryName'] as String,
      );

  Category toEntity() => Category(
        categoryId: categoryId,
        categoryName: categoryName,
      );
}
