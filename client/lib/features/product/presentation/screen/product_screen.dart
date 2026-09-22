import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/features/product/domain/entities/product.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_list_item.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('오류가 발생했습니다.\n$e')),
          data: (products) => _ProductSection(products: products),
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'NEW',
              style: TextStyle(
                color: AppColors.kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              spacing: 15,
              children: products.map((p) => ProductListItem(product: p)).toList(),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
