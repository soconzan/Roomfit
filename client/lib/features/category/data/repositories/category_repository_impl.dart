import 'package:roomfit_client/features/category/data/sources/remote/category_remote_source.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._source);

  final CategoryRemoteSource _source;

  @override
  Future<List<Category>> fetchCategories() async {
    final responses = await _source.fetchCategories();
    return responses.map((r) => r.toEntity()).toList();
  }
}
