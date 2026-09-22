import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';

class ProductViewerNavBar extends StatelessWidget {
  const ProductViewerNavBar({
    super.key,
    this.onTap3d,
    this.onTapAr,
    this.active3d = false,
  });

  final VoidCallback? onTap3d;
  final VoidCallback? onTapAr; // null이면 AR 버튼 비활성화
  final bool active3d;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            color: const Color(0xBFFFFFFF),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavButton(
                  svgPath: 'assets/icons/ic_3d_outline.svg',
                  label: AppStrings.kViewerLabel3d,
                  onTap: onTap3d,
                  isActive: active3d,
                ),
                _NavButton(
                  svgPath: 'assets/icons/ic_ar_outline.svg',
                  label: AppStrings.kViewerLabelAr,
                  onTap: onTapAr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.svgPath,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  final String svgPath;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = onTap != null ? AppColors.kBlack : AppColors.kNavUnselected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color.fromARGB(38, 142, 160, 194)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 7,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 21,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppSizes.kFontSm,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
