import 'package:flutter/material.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceSm,
        vertical: 13,
      ),
      color: AppColors.kWhite,
      child: Row(
        spacing: AppSizes.kSpaceSm,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.kBlack,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: AppColors.kBlack,
                fontSize: AppSizes.kFontMd,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: AppStrings.kSearchHint,
                hintStyle: TextStyle(
                  color: AppColors.kInputHint,
                  fontSize: AppSizes.kFontMd,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.kBlack,
            ),
          ),
        ],
      ),
    );
  }
}
