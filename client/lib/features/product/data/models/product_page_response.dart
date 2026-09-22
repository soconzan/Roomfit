import 'package:roomfit_client/features/product/data/models/product_list_item_response.dart';
import 'package:roomfit_client/features/product/domain/entities/product_page.dart';

class ProductPageResponse {
  const ProductPageResponse({
    required this.products,
    required this.nextCursor,
    required this.hasNext,
  });

  factory ProductPageResponse.fromJson(Map<String, dynamic> json) =>
      ProductPageResponse(
        products: (json['product'] as List<dynamic>)
            .map((e) => ProductListItemResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as int?,
        hasNext: json['hasNext'] as bool,
      );

  final List<ProductListItemResponse> products;
  final int? nextCursor;
  final bool hasNext;

  ProductPage toEntity() => ProductPage(
        products: products.map((r) => r.toEntity()).toList(),
        nextCursor: nextCursor,
        hasNext: hasNext,
      );
}
