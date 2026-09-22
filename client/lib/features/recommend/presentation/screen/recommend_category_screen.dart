import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/platform/ar_launcher.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';

class RecommendCategoryScreen extends ConsumerStatefulWidget {
  const RecommendCategoryScreen({super.key});

  @override
  ConsumerState<RecommendCategoryScreen> createState() =>
      _RecommendCategoryScreenState();
}

class _RecommendCategoryScreenState
    extends ConsumerState<RecommendCategoryScreen> {
  static const _noCategoryId = -1;

  int? _selectedCategoryId;

  bool get _canLaunch => _selectedCategoryId != null;

  Future<void> _launch() async {
    if (!_canLaunch) return;
    final categoryId =
        _selectedCategoryId == _noCategoryId ? null : _selectedCategoryId;
    final uri = Uri.parse(AppApi.arRecommendLink(categoryId: categoryId));
    try {
      await ArLauncher.launch(uri);
    } catch (e) {
      debugPrint('🔴 [ERROR] 추천 딥링크 호출 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.kCategoryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.kSpaceXl,
            AppSizes.kSpaceXl,
            AppSizes.kSpaceXl,
            AppSizes.kSpaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.kSpaceSm,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: AppColors.kBlack,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSizes.kSpaceSm,
                children: [
                  Text(
                    AppStrings.kRecommendTitle,
                    style: const TextStyle(
                      color: AppColors.kModelingPrimaryText,
                      fontSize: AppSizes.kFontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppStrings.kRecommendSubtitle,
                    style: const TextStyle(
                      color: AppColors.kModelingPrimaryText,
                      fontSize: AppSizes.kFontSm,
                      fontWeight: FontWeight.w300,
                      height: 2,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: categoriesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (_, __) => const Center(
                        child: Text(
                          AppStrings.kSearchError,
                          style: TextStyle(
                            color: AppColors.kDetailSubText,
                            fontSize: AppSizes.kFontSm,
                          ),
                        ),
                      ),
                  data:
                      (categories) => _CategoryList(
                        categories: categories,
                        selectedCategoryId: _selectedCategoryId,
                        onSelect:
                            (id) => setState(() => _selectedCategoryId = id),
                      ),
                ),
              ),
              _BottomButton(canLaunch: _canLaunch, onTap: _launch),
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppPaths.recommendResult),
                  child: const Text(
                    '최종발표용 추천 결과 확인',
                    style: TextStyle(
                      color: AppColors.kBlack,
                      fontSize: AppSizes.kFontSm,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelect;

  static const _noCategoryId = _RecommendCategoryScreenState._noCategoryId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: AppSizes.kSpaceSm,
        children: [
          _NoCategoryCard(
            isSelected: selectedCategoryId == _noCategoryId,
            onTap:
                () => onSelect(
                  selectedCategoryId == _noCategoryId ? null : _noCategoryId,
                ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.kSpaceSm,
              mainAxisSpacing: AppSizes.kSpaceSm,
              mainAxisExtent: 60,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              final isSelected = selectedCategoryId == category.categoryId;
              return _CategoryCard(
                category: category,
                isSelected: isSelected,
                onTap: () => onSelect(isSelected ? null : category.categoryId),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NoCategoryCard extends StatelessWidget {
  const _NoCategoryCard({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.kSpaceSm,
          vertical: AppSizes.kSpaceLg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kBlack : AppColors.kWhite,
          borderRadius: BorderRadius.circular(AppSizes.kSpaceSm),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : AppColors.kModelingCardBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            AppStrings.kRecommendNoCategory,
            style: TextStyle(
              color:
                  isSelected
                      ? AppColors.kWhite
                      : AppColors.kModelingPrimaryText,
              fontSize: AppSizes.kFontSm,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.kSpaceLg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kBlack : AppColors.kWhite,
          borderRadius: BorderRadius.circular(AppSizes.kSpaceSm),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : AppColors.kModelingCardBorder,
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                category.categoryName,
                style: TextStyle(
                  color:
                      isSelected
                          ? AppColors.kWhite
                          : AppColors.kModelingPrimaryText,
                  fontSize: AppSizes.kFontSm,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.kWhite,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({required this.canLaunch, required this.onTap});

  final bool canLaunch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: canLaunch ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.kSpaceLg),
          decoration: BoxDecoration(
            color:
                canLaunch ? AppColors.kBlack : AppColors.kBlack.withAlpha(60),
            borderRadius: BorderRadius.circular(AppSizes.kCardRadius * 3),
          ),
          child: const Center(
            child: Text(
              AppStrings.kRecommendButton,
              style: TextStyle(
                color: AppColors.kWhite,
                fontSize: AppSizes.kFontMd,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
