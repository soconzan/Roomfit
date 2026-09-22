import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/shared/presentation/widgets/app_top_bar.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_list_item.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.initialCategoryId,
  });

  final int initialCategoryId;

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  late int _selectedCategoryId;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
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
      ref
          .read(categoryProductsProvider(_selectedCategoryId).notifier)
          .loadMore();
    }
  }

  void _selectCategory(int categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync =
        ref.watch(categoryProductsProvider(_selectedCategoryId));

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              onSearchTap: () => context.push(AppPaths.productSearch),
            ),
            categoriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) => _CategoryTabBar(
                categories: categories,
                selectedId: _selectedCategoryId,
                onSelect: _selectCategory,
              ),
            ),
            Expanded(
              child: productsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text(
                    AppStrings.kSearchError,
                    style: TextStyle(
                      color: AppColors.kSubText,
                      fontSize: AppSizes.kFontSm,
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        AppStrings.kCategoryEmpty,
                        style: TextStyle(
                          color: AppColors.kSubText,
                          fontSize: AppSizes.kFontSm,
                        ),
                      ),
                    );
                  }
                  final hasNext = ref
                      .read(categoryProductsProvider(_selectedCategoryId)
                          .notifier)
                      .hasNext;
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
}

class _CategoryTabBar extends StatelessWidget {
  const _CategoryTabBar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final int selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.kDetailDividerLine),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.kSpaceLg),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSizes.kSpaceSm),
        itemBuilder: (_, index) {
          final category = categories[index];
          final isSelected = category.categoryId == selectedId;
          return GestureDetector(
            onTap: () => onSelect(category.categoryId),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kSpaceSm,
                vertical: AppSizes.kSpaceXs,
              ),
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.kBlack,
                          width: 2,
                        ),
                      ),
                    )
                  : null,
              child: Text(
                category.categoryName,
                style: TextStyle(
                  color: isSelected ? AppColors.kBlack : AppColors.kSubText,
                  fontSize: AppSizes.kFontSm,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
