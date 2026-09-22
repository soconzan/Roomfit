import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:intl/intl.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/product/domain/entities/product.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/features/profile/domain/entities/user_profile.dart';
import 'package:roomfit_client/features/profile/presentation/provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) =>
                        Center(child: Text('${AppStrings.kProfileError}\n$e')),
                data: (profile) => _buildContent(context, ref, profile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceLg,
        vertical: AppSizes.kSpaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            AppStrings.kProfileTitle,
            style: TextStyle(
              fontFamily: 'A2Z',
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w900,
            ),
          ),
          Icon(
            Icons.notifications_none,
            color: AppColors.kBlack,
            size: AppSizes.kIconMd,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final myProductsAsync = ref.watch(myProductsPreviewProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.kSpaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(profile),
          const SizedBox(height: AppSizes.kSpaceSm),
          _buildProductsCard(context, myProductsAsync.valueOrNull ?? []),
          const SizedBox(height: AppSizes.kSpaceSm),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kCardPaddingH,
        vertical: AppSizes.kCardPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.kProfileCardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        spacing: AppSizes.kSpaceSm,
        children: [
          _buildAvatar(profile.imageUrl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.kSpaceXs,
            children: [
              Text(
                profile.nickname,
                style: const TextStyle(
                  color: AppColors.kBlack,
                  fontSize: AppSizes.kFontMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                profile.username,
                style: const TextStyle(
                  color: AppColors.kProfileSubText,
                  fontSize: AppSizes.kFontXs,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    const size = AppSizes.kAvatarMd;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _defaultAvatar(size),
        ),
      );
    }
    return _defaultAvatar(size);
  }

  Widget _defaultAvatar(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Image.asset(
        'assets/images/default_avatar.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProductsCard(BuildContext context, List<Product> products) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kCardPaddingH,
        vertical: AppSizes.kCardPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.kProfileCardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.kSpaceSm,
        children: [
          GestureDetector(
            onTap: () => context.push(AppPaths.myProducts),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.kProfileSales,
                  style: TextStyle(
                    color: AppColors.kBlack,
                    fontSize: AppSizes.kFontSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.kBlack,
                  size: AppSizes.kIconSm,
                ),
              ],
            ),
          ),
          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.kSpaceSm,
                ),
                child: Text(
                  AppStrings.kProfileEmpty,
                  style: const TextStyle(
                    color: AppColors.kProfileSubText,
                    fontSize: AppSizes.kFontSm,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: AppSizes.kSpaceSm,
                children:
                    products.map((p) => _ProductThumbnail(product: p)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) context.go(AppPaths.home);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.kSpaceMd),
        decoration: BoxDecoration(
          color: AppColors.kProfileLogoutBg,
          borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.kProfileCardShadow,
              blurRadius: 10,
              offset: Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            AppStrings.kProfileLogout,
            style: TextStyle(
              color: AppColors.kProfileLogoutText,
              fontSize: AppSizes.kFontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});

  final Product product;

  String _formatPrice(int price) => '${NumberFormat('#,###').format(price)}원';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.productId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.kSpaceXs,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              imageUrl: product.thumbnailUrl,
              width: AppSizes.kThumbnailSm,
              height: AppSizes.kThumbnailSm,
              fit: BoxFit.cover,
              errorWidget:
                  (_, __, ___) => ColoredBox(
                    color: AppColors.kDetailDividerLine,
                    child: const SizedBox(
                      width: AppSizes.kThumbnailSm,
                      height: AppSizes.kThumbnailSm,
                    ),
                  ),
            ),
          ),
          SizedBox(
            width: AppSizes.kThumbnailSm,
            child: Text(
              product.productName,
              style: const TextStyle(
                color: AppColors.kBlack,
                fontSize: AppSizes.kFontXs,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatPrice(product.productPrice),
            style: const TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
