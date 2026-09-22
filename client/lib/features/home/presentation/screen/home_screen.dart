import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/shared/presentation/widgets/app_top_bar.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_create_fab.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isRefreshing = false;

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
      ref.read(productsNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(productsNotifierProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(onSearchTap: () => context.push(AppPaths.productSearch)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.transparent,
                backgroundColor: Colors.transparent,
                strokeWidth: 0,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (_isRefreshing)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: LoadingAnimationWidget.bouncingBall(
                              color: AppColors.kBlack,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
                        child: _DiscoveryBanner(
                          onTap: () => context.push(AppPaths.recommendCategory),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontFamily: 'A2Z',
                            color: AppColors.kBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    ...productsAsync.when(
                      loading:
                          () => const [
                            SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ],
                      error:
                          (e, _) => [
                            SliverToBoxAdapter(
                              child: Center(child: Text('오류가 발생했습니다.\n$e')),
                            ),
                          ],
                      data: (products) {
                        final hasNext =
                            ref.read(productsNotifierProvider.notifier).hasNext;
                        return [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            sliver: SliverList.separated(
                              itemCount: products.length,
                              itemBuilder:
                                  (_, index) =>
                                      ProductListItem(product: products[index]),
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 15),
                            ),
                          ),
                          if (hasNext)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: LoadingAnimationWidget.waveDots(
                                    color: AppColors.kGray,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 90)),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 0 + MediaQuery.of(context).padding.bottom,
        ),
        child: ProductCreateFab(
          onTap: () {
            final isLoggedIn = ref.read(isLoggedInProvider);
            context.push(isLoggedIn ? AppPaths.productCreate : AppPaths.login);
          },
        ),
      ),
    );
  }
}

class _DiscoveryBanner extends StatelessWidget {
  const _DiscoveryBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kBlack,
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Stack(
          children: [
            Text(
              AppStrings.kHomeBannerTitle,
              style: TextStyle(
                color: AppColors.kWhite,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.kWhite,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
