import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';

class ModelingMethodScreen extends StatelessWidget {
  const ModelingMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kCategoryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kSpaceXl,
            vertical: AppSizes.kSpaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 30,
            children: [
              _buildAppBar(context),
              _buildRecommendNote(),
              _buildButtonGrid(context),
              _buildAlbumNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        spacing: 15,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.kBlack,
              size: 20,
            ),
          ),
          const Text(
            AppStrings.kModelingTitle,
            style: TextStyle(
              color: AppColors.kBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendNote() {
    return Column(
      spacing: 15,
      children: [
        SvgPicture.asset(
          'assets/icons/ic_layer_sparkle.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(
            AppColors.kModelingPrimaryText,
            BlendMode.srcIn,
          ),
        ),
        const Text(
          AppStrings.kModelingRecommendNote,
          style: TextStyle(
            color: AppColors.kModelingPrimaryText,
            fontSize: AppSizes.kFontSm,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _ModelingCard(
                svgPath: 'assets/icons/ic_camera_outline.svg',
                label: AppStrings.kModelingSingleView,
                onTap: () => context.push(AppPaths.modelingCameraSingle),
              ),
            ),
            Expanded(
              child: _ModelingCard(
                svgPath: 'assets/icons/ic_rotate_camera.svg',
                label: AppStrings.kModelingMultiView,
                onTap: () async {
                  final photos = await context.push(
                    AppPaths.modelingCameraMulti,
                  );
                  if (photos != null && context.mounted) context.pop(photos);
                },
              ),
            ),
          ],
        ),
        _ModelingAlbumCard(
          onTap: () => context.push(AppPaths.modelingCreateAlbum),
        ),
      ],
    );
  }

  Widget _buildAlbumNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          const Row(
            spacing: 7,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.kModelingSecondaryText,
                size: 18,
              ),
              Text(
                AppStrings.kModelingNoteTitle,
                style: TextStyle(
                  color: AppColors.kModelingPrimaryText,
                  fontSize: AppSizes.kFontMd,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                AppStrings.kModelingNoteItems
                    .map(
                      (item) => Text(
                        '• $item',
                        style: const TextStyle(
                          color: AppColors.kModelingPrimaryText,
                          fontSize: AppSizes.kFontXs,
                          fontWeight: FontWeight.w300,
                          height: 1.67,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _ModelingCard extends StatelessWidget {
  const _ModelingCard({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        height: 194,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          border: Border.all(width: 1, color: AppColors.kModelingCardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 50,
              height: 50,
              colorFilter: const ColorFilter.mode(
                AppColors.kModelingSecondaryText,
                BlendMode.srcIn,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.kModelingPrimaryText,
                fontSize: AppSizes.kFontMd,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelingAlbumCard extends StatelessWidget {
  const _ModelingAlbumCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        width: double.infinity,
        height: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          border: Border.all(width: 1, color: AppColors.kModelingCardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_gallery_outline.svg',
              width: 2,
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.kModelingSecondaryText,
                BlendMode.srcIn,
              ),
            ),
            const Text(
              AppStrings.kModelingAlbum,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.kModelingPrimaryText,
                fontSize: AppSizes.kFontMd,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
