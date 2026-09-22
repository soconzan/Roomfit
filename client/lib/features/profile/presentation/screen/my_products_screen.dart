import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_list_item.dart';

class MyProductsScreen extends ConsumerStatefulWidget {
  const MyProductsScreen({super.key});

  @override
  ConsumerState<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends ConsumerState<MyProductsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(myProductsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Expanded(
              child: productsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(
                    AppStrings.kProfileError,
                    style: const TextStyle(
                      color: AppColors.kDetailSubText,
                      fontSize: AppSizes.kFontSm,
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.kProfileEmpty,
                        style: const TextStyle(
                          color: AppColors.kDetailSubText,
                          fontSize: AppSizes.kFontSm,
                        ),
                      ),
                    );
                  }
                  final hasNext =
                      ref.read(myProductsProvider.notifier).hasNext;
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.kSpaceLg,
                      vertical: AppSizes.kSpaceXl,
                    ),
                    itemCount: products.length + (hasNext ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.kSpaceLg),
                    itemBuilder: (_, index) {
                      if (index >= products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ProductListItem(product: products[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceLg,
        vertical: AppSizes.kSpaceSm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.kBlack,
            ),
          ),
          const SizedBox(width: AppSizes.kSpaceSm),
          const Text(
            AppStrings.kProfileSales,
            style: TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
