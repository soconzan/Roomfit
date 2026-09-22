import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/product/presentation/provider/recent_search_provider.dart';
import 'package:roomfit_client/features/product/presentation/widgets/product_search_bar.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    ref.read(recentSearchProvider.notifier).add(trimmed);
    final shouldClear = await context.push<bool>(
      AppPaths.productSearchResult,
      extra: trimmed,
    );
    if (shouldClear == true) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _search,
              onClear: () => _controller.clear(),
              onBack: () => context.pop(),
            ),
            Container(height: 0.8, color: AppColors.kSearchDivider),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kSpaceLg,
                vertical: AppSizes.kSpaceXl,
              ),
              child: const Text(
                AppStrings.kSearchRecentTitle,
                style: TextStyle(
                  color: AppColors.kBlack,
                  fontSize: AppSizes.kFontSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            recentAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data:
                  (items) => Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kSpaceLg,
                      ),
                      itemCount: items.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(height: AppSizes.kSpaceXl - 2),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return Row(
                          spacing: AppSizes.kSpaceSm,
                          children: [
                            const Icon(
                              Icons.history,
                              size: 20,
                              color: AppColors.kSearchItemText,
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _controller.text = item;
                                  _search(item);
                                },
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: AppColors.kSearchItemText,
                                    fontSize: AppSizes.kFontSm,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => ref
                                      .read(recentSearchProvider.notifier)
                                      .remove(item),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.kSearchItemText,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
