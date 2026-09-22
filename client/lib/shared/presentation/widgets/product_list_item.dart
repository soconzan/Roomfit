import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/features/product/domain/entities/product.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({super.key, required this.product});

  final Product product;

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return '$result원';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/products/${product.productId}'),
      borderRadius: BorderRadius.circular(7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: product.thumbnailUrl,
              width: 100,
              height: 100,
              memCacheWidth: 200,
              fit: BoxFit.cover,
              errorWidget:
                  (_, __, ___) => const ColoredBox(color: Color(0xFFF0F0F0)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      color: AppColors.kBlack,
                      fontSize: AppSizes.kFontSm,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatPrice(product.productPrice),
                    style: const TextStyle(
                      color: AppColors.kBlack,
                      fontSize: AppSizes.kFontSm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    product.categoryName,
                    style: const TextStyle(
                      color: AppColors.kSubText,
                      fontSize: AppSizes.kFontXs,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
