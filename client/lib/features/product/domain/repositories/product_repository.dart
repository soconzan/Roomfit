import 'package:roomfit_client/features/product/domain/entities/create_product_params.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/domain/entities/product_model.dart';
import 'package:roomfit_client/features/product/domain/entities/product_page.dart';
import 'package:roomfit_client/features/product/domain/entities/update_product_params.dart';

abstract interface class ProductRepository {
  Future<ProductPage> fetchProducts({int? cursor, int? categoryId});
  Future<ProductDetail> fetchProductDetail(int id);
  Future<ProductModel> fetchProductModel(int id);
  Future<void> createProduct(CreateProductParams params);
  Future<void> updateProduct(UpdateProductParams params);
  Future<ProductPage> searchProducts({String? keyword, int? cursor});
  Future<ProductPage> fetchMyProducts({int? cursor});
  Future<void> deleteProduct(int id);
}
