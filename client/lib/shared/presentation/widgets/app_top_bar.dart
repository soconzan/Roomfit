import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceXl,
        vertical: AppSizes.kSpaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            AppStrings.kAppName,
            style: TextStyle(
              fontFamily: 'A2Z',
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            spacing: 17,
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: SvgPicture.asset(
                  'assets/icons/ic_search.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.kBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/ic_bell_outline.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.kBlack,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
