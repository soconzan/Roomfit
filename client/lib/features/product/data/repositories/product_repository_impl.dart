import 'package:roomfit_client/features/product/data/sources/remote/product_remote_source.dart';
import 'package:roomfit_client/features/product/domain/entities/create_product_params.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/domain/entities/product_model.dart';
import 'package:roomfit_client/features/product/domain/entities/product_page.dart';
import 'package:roomfit_client/features/product/domain/entities/update_product_params.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._source);

  final ProductRemoteSource _source;

  @override
  Future<ProductPage> fetchProducts({int? cursor, int? categoryId}) async {
    final response = await _source.fetchProducts(cursor: cursor, categoryId: categoryId);
    return response.toEntity();
  }

  @override
  Future<ProductDetail> fetchProductDetail(int id) async {
    final response = await _source.fetchProductDetail(id);
    return response.toEntity();
  }

  @override
  Future<ProductModel> fetchProductModel(int id) async {
    final response = await _source.fetchProductModel(id);
    return response.toEntity();
  }

  @override
  Future<void> createProduct(CreateProductParams params) =>
      _source.createProduct(params);

  @override
  Future<void> updateProduct(UpdateProductParams params) =>
      _source.updateProduct(params);

  @override
  Future<ProductPage> searchProducts({String? keyword, int? cursor}) async {
    final response = await _source.searchProducts(keyword: keyword, cursor: cursor);
    return response.toEntity();
  }

  @override
  Future<ProductPage> fetchMyProducts({int? cursor}) async {
    final response = await _source.fetchMyProducts(cursor: cursor);
    return response.toEntity();
  }

  @override
  Future<void> deleteProduct(int id) => _source.deleteProduct(id);
}
