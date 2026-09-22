import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({
    super.key,
    required this.userId,
    required this.nickname,
    this.userImageUrl,
  });

  final String userId;
  final String nickname;
  final String? userImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: AppSizes.kSpaceXl),
            _buildProfileInfo(),
            const SizedBox(height: AppSizes.kSpaceXl),
            Container(height: 0.8, color: AppColors.kDetailDividerLine),
            _buildSalesSection(),
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
            AppStrings.kSellerProfileTitle,
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

  Widget _buildProfileInfo() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: AppSizes.kAvatarMd,
            backgroundColor: AppColors.kDetailDividerLine,
            backgroundImage: userImageUrl != null
                ? CachedNetworkImageProvider(userImageUrl!) as ImageProvider
                : const AssetImage('assets/images/default_avatar.png'),
          ),
          const SizedBox(height: AppSizes.kSpaceSm),
          Text(
            nickname,
            style: const TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.kSpaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.kProfileSales,
            style: TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.kSpaceLg),
          const Center(
            child: Text(
              AppStrings.kProfileEmpty,
              style: TextStyle(
                color: AppColors.kDetailSubText,
                fontSize: AppSizes.kFontSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
