import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/features/product/domain/entities/product.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/core/platform/ar_launcher.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/product/presentation/screen/product_image_viewer_screen.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_viewer_nav_bar.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: detailAsync.when(
        loading:
            () => Column(
              children: [
                _DetailTopBar(),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
        error:
            (e, _) => Column(
              children: [
                _DetailTopBar(),
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.kDetailError,
                      style: const TextStyle(
                        color: AppColors.kDetailSubText,
                        fontSize: AppSizes.kFontSm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        data: (detail) {
          final currentUserId = ref.watch(currentUserIdProvider).valueOrNull;
          final isOwner =
              currentUserId != null && currentUserId == detail.userId;
          final modelUrl =
              ref.watch(productModelProvider(id)).valueOrNull?.modelUrl;
          return _DetailBody(
            productId: id,
            detail: detail,
            isOwner: isOwner,
            modelUrl: modelUrl,
            onDelete: () async {
              await ref.read(deleteProductUseCaseProvider).call(id);
              ref.invalidate(myProductsPreviewProvider);
              ref.invalidate(myProductsProvider);
            },
          );
        },
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({this.onMore});

  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.kSpaceLg,
          vertical: AppSizes.kSpaceMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.kBlack,
                size: 20,
              ),
            ),
            if (onMore != null)
              GestureDetector(
                onTap: onMore,
                child: const Icon(
                  Icons.more_horiz,
                  color: AppColors.kBlack,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.productId,
    required this.detail,
    required this.isOwner,
    required this.onDelete,
    this.modelUrl,
  });

  final int productId;
  final ProductDetail detail;
  final bool isOwner;
  final Future<void> Function() onDelete;
  final String? modelUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailTopBar(onMore: isOwner ? () => _showMoreMenu(context) : null),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: _ImageSection(
                            productId: productId,
                            imageUrls: detail.imageUrls,
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      child: ProductViewerNavBar(
                        onTap3d:
                            modelUrl == null
                                ? null
                                : () => context.push(
                                  AppPaths.product3dViewerPath(productId),
                                  extra: {
                                    'width': detail.productWidth,
                                    'height': detail.productHeight,
                                    'depth': detail.productDepth,
                                  },
                                ),
                        onTapAr:
                            modelUrl == null
                                ? null
                                : () async {
                                  final uri = Uri.parse(
                                    AppApi.arDetailLink(
                                      productId: productId,
                                      modelUrl: modelUrl!,
                                      width: detail.productWidth,
                                      height: detail.productHeight,
                                      depth: detail.productDepth,
                                    ),
                                  );
                                  await ArLauncher.launch(uri);
                                },
                      ),
                    ),
                  ],
                ),
                _buildInfoSection(detail),
                _buildSellerSection(context, detail),
                Container(height: 0.8, color: AppColors.kDetailDividerLine),
                _buildDescriptionSection(context, detail),
                const SizedBox(height: AppSizes.kSpaceXl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ProductDetail detail) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: AppSizes.kSpaceLg,
        left: AppSizes.kSpaceLg,
        right: AppSizes.kSpaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.kSpaceSm,
        children: [
          Text(
            detail.categoryName,
            style: const TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontXs,
              decoration: TextDecoration.underline,
            ),
          ),
          Text(
            detail.productName,
            style: const TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _formatPrice(detail.productPrice),
            style: const TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _relativeTime(detail.createdAt),
            style: const TextStyle(
              color: AppColors.kDetailSubText,
              fontSize: AppSizes.kFontXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection(BuildContext context, ProductDetail detail) {
    return InkWell(
      onTap:
          () => context.push(
            AppPaths.sellerProfilePath(detail.userId),
            extra: {
              'nickname': detail.nickname,
              'userImageUrl': detail.userImageUrl,
            },
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.kSpaceLg,
          vertical: AppSizes.kSpaceMd,
        ),
        child: Row(
          spacing: AppSizes.kSpaceSm,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.kDetailDividerLine,
              backgroundImage:
                  detail.userImageUrl != null
                      ? CachedNetworkImageProvider(detail.userImageUrl!)
                          as ImageProvider
                      : const AssetImage('assets/images/default_avatar.png'),
            ),
            Text(
              detail.nickname,
              style: const TextStyle(
                color: AppColors.kBlack,
                fontSize: AppSizes.kFontSm,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
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

  Widget _buildDescriptionSection(BuildContext context, ProductDetail detail) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.kSpaceLg,
        AppSizes.kSpaceLg,
        AppSizes.kSpaceLg,
        AppSizes.kSpaceLg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.kSpaceLg,
        children: [
          Text(
            detail.description,
            style: const TextStyle(
              color: AppColors.kDetailDescText,
              fontSize: AppSizes.kFontSm,
              height: 1.67,
            ),
          ),
          Text(
            _formatDimensions(detail),
            style: const TextStyle(
              color: AppColors.kDetailSubText,
              fontSize: AppSizes.kFontXs,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.kDetailMenuBarrier,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              left: AppSizes.kSpaceMd,
              right: AppSizes.kSpaceMd,
              bottom: AppSizes.kSpaceMd + MediaQuery.of(context).padding.bottom,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.kSpaceSm),
              decoration: BoxDecoration(
                color: AppColors.kDetailMenuBg,
                borderRadius: BorderRadius.circular(AppSizes.kDetailMenuRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSizes.kSpaceSm,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.kSpaceSm,
                      vertical: AppSizes.kSpaceLg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.kWhite,
                      borderRadius: BorderRadius.circular(
                        AppSizes.kDetailMenuItemRadius,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSizes.kSpaceLg,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.push(
                              AppPaths.productEditPath(productId),
                              extra: detail,
                            );
                          },
                          child: Row(
                            spacing: AppSizes.kSpaceSm,
                            children: const [
                              Icon(Icons.edit_outlined, size: 16),
                              Text(
                                AppStrings.kDetailEditPost,
                                style: TextStyle(
                                  fontSize: AppSizes.kFontMd,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.5,
                          color: AppColors.kDetailMenuDivider,
                        ),
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: AppColors.kDetailMenuBarrier,
                              builder:
                                  (_) => Center(
                                    child: LoadingAnimationWidget.newtonCradle(
                                      color: AppColors.kWhite,
                                      size: 60,
                                    ),
                                  ),
                            );
                            try {
                              await onDelete();
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              await showDialog<void>(
                                context: context,
                                barrierColor: AppColors.kDetailMenuBarrier,
                                builder:
                                    (_) => AlertDialog(
                                      content: const Text(
                                        AppStrings.kDetailDeleteSuccess,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            context.pop();
                                          },
                                          child: const Text('확인'),
                                        ),
                                      ],
                                    ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              showDialog<void>(
                                context: context,
                                barrierColor: AppColors.kDetailMenuBarrier,
                                builder:
                                    (_) => AlertDialog(
                                      content: const Text(
                                        AppStrings.kDetailDeleteError,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('확인'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                          child: Row(
                            spacing: AppSizes.kSpaceSm,
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppColors.kDetailDeleteRed,
                              ),
                              Text(
                                AppStrings.kDetailDeletePost,
                                style: TextStyle(
                                  fontSize: AppSizes.kFontMd,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.kDetailDeleteRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.kSpaceSm),
                      decoration: BoxDecoration(
                        color: AppColors.kWhite,
                        borderRadius: BorderRadius.circular(
                          AppSizes.kDetailMenuItemRadius,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          AppStrings.kDetailClose,
                          style: TextStyle(
                            fontSize: AppSizes.kFontMd,
                            fontWeight: FontWeight.w500,
                          ),
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

  String _formatPrice(int price) {
    return '${NumberFormat('#,###').format(price)}원';
  }

  String _relativeTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}주 전';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}달 전';
    return '${diff.inDays ~/ 365}년 전';
  }

  String _formatDimensions(ProductDetail d) {
    String fmt(double v) => (v / 10).toStringAsFixed(1);
    return '가로 ${fmt(d.productWidth)}cm × 세로 ${fmt(d.productDepth)}cm × 높이 ${fmt(d.productHeight)}cm';
  }
}

class _ImageSection extends StatefulWidget {
  const _ImageSection({required this.productId, required this.imageUrls});

  final int productId;
  final List<String> imageUrls;

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  final _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemCount: widget.imageUrls.length,
          itemBuilder:
              (context, i) => GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (_) => ProductImageViewerScreen(
                              imageUrls: widget.imageUrls,
                              initialIndex: _currentIndex,
                            ),
                      ),
                    ),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[i],
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                ),
              ),
        ),
        Positioned(
          right: AppSizes.kSpaceSm,
          top: AppSizes.kSpaceSm,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.kSpaceXs),
            decoration: BoxDecoration(
              color: AppColors.kDetailCounterBg,
              borderRadius: BorderRadius.circular(
                AppSizes.kDetailImageCounterRadius,
              ),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.imageUrls.length}',
              style: const TextStyle(
                color: AppColors.kWhite,
                fontSize: AppSizes.kFontXs,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
