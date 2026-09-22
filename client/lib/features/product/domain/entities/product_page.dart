import 'package:roomfit_client/features/product/domain/entities/product.dart';

class ProductPage {
  const ProductPage({
    required this.products,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<Product> products;
  final int? nextCursor;
  final bool hasNext;
}
