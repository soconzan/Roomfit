import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';

class ModelingCreateAlbumScreen extends StatelessWidget {
  const ModelingCreateAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.kBlack,
                  size: 20,
                ),
              ),
            ),
            const Expanded(
              child: Center(child: Text('앨범에서 모델 생성')),
            ),
          ],
        ),
      ),
    );
  }
}
