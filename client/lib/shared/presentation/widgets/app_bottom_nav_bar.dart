import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _recommendIndex = 2;

  static const _items = [
    _NavItem(
      svgPath: 'assets/icons/ic_home_filled.svg',
      label: AppStrings.kNavHome,
    ),
    _NavItem(
      svgPath: 'assets/icons/ic_grid_search_filled.svg',
      label: AppStrings.kNavCategory,
    ),
    _NavItem(
      svgPath: 'assets/icons/ic_recommend.svg',
      label: AppStrings.kNavRecommend,
    ),
    _NavItem(
      svgPath: 'assets/icons/ic_profile_filled.svg',
      label: AppStrings.kNavProfile,
    ),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == _recommendIndex) {
      context.push(AppPaths.recommendCategory);
      return;
    }
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(15, 0, 0, 0),
            blurRadius: 13,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 10),
          child: Container(
            color: const Color.fromARGB(174, 255, 255, 255),
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 8,
              bottom: bottomPadding + 8,
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                final isSelected = i == currentIndex;
                final color =
                    isSelected ? AppColors.kBlack : AppColors.kNavUnselected;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTap(context, i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 3,
                      children: [
                        SvgPicture.asset(
                          _items[i].svgPath,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.svgPath, required this.label});

  final String svgPath;
  final String label;
}
