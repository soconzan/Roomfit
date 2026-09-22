import 'package:roomfit_client/features/category/domain/entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> fetchCategories();
}
