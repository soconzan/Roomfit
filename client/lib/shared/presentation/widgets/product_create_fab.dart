import 'package:flutter/material.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';

class ProductCreateFab extends StatelessWidget {
  const ProductCreateFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.kBlack,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.kFabShadow,
              blurRadius: 24,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.kWhite, size: 28),
      ),
    );
  }
}
