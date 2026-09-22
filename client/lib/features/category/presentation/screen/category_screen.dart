import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryAppBar(),
            Expanded(
              child: ColoredBox(
                color: AppColors.kCategoryBg,
                child: categoriesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (_, __) => const Center(
                        child: Text(
                          '카테고리를 불러올 수 없습니다.',
                          style: TextStyle(
                            color: AppColors.kSubText,
                            fontSize: AppSizes.kFontSm,
                          ),
                        ),
                      ),
                  data: (categories) => _CategoryGrid(categories: categories),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceLg,
        vertical: 13,
      ),
      child: const Text(
        AppStrings.kCategoryTitle,
        style: TextStyle(
          color: AppColors.kBlack,
          fontSize: AppSizes.kFontLg,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final rowCount = (categories.length / 2).ceil();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
          top: AppSizes.kSpaceLg,
          left: AppSizes.kSpaceLg,
          right: AppSizes.kSpaceLg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.kWhite,
          border: Border(
            bottom: BorderSide(color: AppColors.kDetailDividerLine),
          ),
        ),
        child: Column(
          children: List.generate(rowCount, (rowIndex) {
            final leftIndex = rowIndex * 2;
            final rightIndex = leftIndex + 1;
            final isLastRow = rowIndex == rowCount - 1;
            return Row(
              spacing: AppSizes.kSpaceSm,
              children: [
                Expanded(
                  child: _CategoryItem(
                    category: categories[leftIndex],
                    isLast: isLastRow,
                  ),
                ),
                Container(width: 1, color: AppColors.kDetailDividerLine),
                Expanded(
                  child:
                      rightIndex < categories.length
                          ? _CategoryItem(
                            category: categories[rightIndex],
                            isLast: isLastRow,
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category, this.isLast = false});

  final Category category;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => context.push(
            AppPaths.productCategory,
            extra: category.categoryId,
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.kSpaceXs,
          vertical: AppSizes.kSpaceXl,
        ),
        decoration: BoxDecoration(
          border:
              isLast
                  ? null
                  : const Border(
                    bottom: BorderSide(color: AppColors.kDetailDividerLine),
                  ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.categoryName,
              style: const TextStyle(
                color: AppColors.kBlack,
                fontSize: AppSizes.kFontSm,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.kIconSm,
              color: AppColors.kBlack,
            ),
          ],
        ),
      ),
    );
  }
}
