import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/features/product/presentation/provider/recent_search_provider.dart';
import 'package:roomfit_client/features/product/presentation/widgets/product_search_bar.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_list_item.dart';

class ProductSearchResultScreen extends ConsumerStatefulWidget {
  const ProductSearchResultScreen({super.key, required this.keyword});

  final String keyword;

  @override
  ConsumerState<ProductSearchResultScreen> createState() =>
      _ProductSearchResultScreenState();
}

class _ProductSearchResultScreenState
    extends ConsumerState<ProductSearchResultScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.keyword);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref
          .read(searchProductsProvider(widget.keyword).notifier)
          .loadMore();
    }
  }

  void _search(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    ref.read(recentSearchProvider.notifier).add(trimmed);
    context.pop();
    context.push(AppPaths.productSearchResult, extra: trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(searchProductsProvider(widget.keyword));

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            ProductSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _search,
              onClear: () => context.pop(true),
              onBack: () => context.pop(false),
            ),
            Container(height: 0.8, color: AppColors.kSearchDivider),
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
                        AppStrings.kSearchEmpty,
                        style: TextStyle(
                          color: AppColors.kSubText,
                          fontSize: AppSizes.kFontSm,
                        ),
                      ),
                    );
                  }
                  final hasNext = ref
                      .read(searchProductsProvider(widget.keyword).notifier)
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
