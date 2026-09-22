import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';
import 'package:roomfit_client/features/recommend/presentation/provider/recommend_provider.dart';

class RecommendResultScreen extends ConsumerStatefulWidget {
  const RecommendResultScreen({super.key});

  @override
  ConsumerState<RecommendResultScreen> createState() =>
      _RecommendResultScreenState();
}

class _RecommendResultScreenState
    extends ConsumerState<RecommendResultScreen> {
  XFile? _selectedImage;
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController = TextEditingController();
  Category? _selectedCategory;

  bool get _canSubmit =>
      _selectedImage != null &&
      _widthController.text.trim().isNotEmpty &&
      _heightController.text.trim().isNotEmpty &&
      _depthController.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _selectedImage = file);
  }

  Future<void> _submit() async {
    final image = _selectedImage;
    if (image == null) return;
    final widthCm = double.tryParse(_widthController.text.trim());
    final heightCm = double.tryParse(_heightController.text.trim());
    final depthCm = double.tryParse(_depthController.text.trim());
    if (widthCm == null || heightCm == null || depthCm == null) return;

    // UI는 cm 단위 입력, 서버는 mm 단위 사용
    await ref.read(recommendProvider.notifier).recommend(
          RecommendRequestParams(
            image: image,
            width: widthCm * 10,
            height: heightCm * 10,
            depth: depthCm * 10,
            categoryId: _selectedCategory?.categoryId,
          ),
        );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendAsync = ref.watch(recommendProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kSpaceXl,
                vertical: AppSizes.kSpaceMd,
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
                  const SizedBox(width: 8),
                  const Text(
                    '추천 결과 확인',
                    style: TextStyle(
                      fontSize: AppSizes.kFontLg,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kBlack,
                    ),
                  ),
                ],
              ),
            ),
            // 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.kSpaceXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 이미지 업로드 버튼
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.kCategoryBg,
                          borderRadius: BorderRadius.circular(
                            AppSizes.kCardRadius,
                          ),
                          border: Border.all(
                            color: AppColors.kModelingCardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: AppColors.kDetailSubText,
                            ),
                            const SizedBox(width: AppSizes.kSpaceSm),
                            Text(
                              _selectedImage == null ? '이미지 불러오기' : '이미지 변경',
                              style: const TextStyle(
                                color: AppColors.kDetailSubText,
                                fontSize: AppSizes.kFontSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 이미지 미리보기
                    if (_selectedImage != null) ...[
                      const SizedBox(height: AppSizes.kSpaceMd),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.kCardRadius,
                        ),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.kSpaceLg),

                    // 치수 입력
                    const Text(
                      '가구 치수 (cm)',
                      style: TextStyle(
                        fontSize: AppSizes.kFontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kBlack,
                      ),
                    ),
                    const SizedBox(height: AppSizes.kSpaceSm),
                    Row(
                      children: [
                        Expanded(
                          child: _DimensionField(
                            controller: _widthController,
                            label: '가로',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: AppSizes.kSpaceSm),
                        Expanded(
                          child: _DimensionField(
                            controller: _heightController,
                            label: '세로',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: AppSizes.kSpaceSm),
                        Expanded(
                          child: _DimensionField(
                            controller: _depthController,
                            label: '높이',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.kSpaceLg),

                    // 카테고리 선택
                    const Text(
                      '카테고리',
                      style: TextStyle(
                        fontSize: AppSizes.kFontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kBlack,
                      ),
                    ),
                    const SizedBox(height: AppSizes.kSpaceSm),
                    categoriesAsync.when(
                      loading: () => const SizedBox(
                        height: 52,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (categories) => _CategoryDropdown(
                        categories: categories,
                        selectedCategory: _selectedCategory,
                        onChanged:
                            (c) => setState(() => _selectedCategory = c),
                      ),
                    ),

                    const SizedBox(height: AppSizes.kSpaceLg),

                    // 추천 요청 버튼
                    GestureDetector(
                      onTap:
                          (_canSubmit && !recommendAsync.isLoading)
                              ? _submit
                              : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.kSpaceLg,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _canSubmit
                                  ? AppColors.kBlack
                                  : AppColors.kBlack.withAlpha(60),
                          borderRadius: BorderRadius.circular(
                            AppSizes.kCardRadius * 3,
                          ),
                        ),
                        child: Center(
                          child:
                              recommendAsync.isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.kWhite,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    '추천 받기',
                                    style: TextStyle(
                                      color: AppColors.kWhite,
                                      fontSize: AppSizes.kFontMd,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    // 오류 표시
                    if (recommendAsync.hasError) ...[
                      const SizedBox(height: AppSizes.kSpaceMd),
                      Text(
                        '오류: ${recommendAsync.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: AppSizes.kFontSm,
                        ),
                      ),
                    ],

                    // 추천 결과
                    if (recommendAsync.valueOrNull?.isNotEmpty == true) ...[
                      const SizedBox(height: AppSizes.kSpaceLg),
                      const Text(
                        '추천 결과',
                        style: TextStyle(
                          fontSize: AppSizes.kFontMd,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kBlack,
                        ),
                      ),
                      const SizedBox(height: AppSizes.kSpaceSm),
                      _MasonryGrid(results: recommendAsync.value!),
                    ],

                    const SizedBox(height: AppSizes.kSpaceXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.kFontXs,
            color: AppColors.kDetailSubText,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_DecimalFormatter()],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
              borderSide: const BorderSide(color: AppColors.kModelingCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
              borderSide: const BorderSide(color: AppColors.kModelingCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
              borderSide: const BorderSide(color: AppColors.kBlack),
            ),
            suffixText: 'cm',
            suffixStyle: const TextStyle(
              fontSize: AppSizes.kFontXs,
              color: AppColors.kDetailSubText,
            ),
          ),
          style: const TextStyle(fontSize: AppSizes.kFontSm),
        ),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kModelingCardBorder),
        borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category?>(
          value: selectedCategory,
          isExpanded: true,
          hint: const Text(
            '선택 안 함',
            style: TextStyle(
              fontSize: AppSizes.kFontSm,
              color: AppColors.kDetailSubText,
            ),
          ),
          items: [
            const DropdownMenuItem<Category?>(
              value: null,
              child: Text(
                '선택 안 함',
                style: TextStyle(fontSize: AppSizes.kFontSm),
              ),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<Category?>(
                value: c,
                child: Text(
                  c.categoryName,
                  style: const TextStyle(fontSize: AppSizes.kFontSm),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MasonryGrid extends StatelessWidget {
  const _MasonryGrid({required this.results});

  final List<RecommendResult> results;

  @override
  Widget build(BuildContext context) {
    final left = <RecommendResult>[];
    final right = <RecommendResult>[];
    for (var i = 0; i < results.length; i++) {
      if (i.isEven) {
        left.add(results[i]);
      } else {
        right.add(results[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: left.map(_RecommendCard.new).toList(),
          ),
        ),
        const SizedBox(width: AppSizes.kSpaceSm),
        Expanded(
          child: Column(
            children: right.map(_RecommendCard.new).toList(),
          ),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard(this.result);

  final RecommendResult result;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat('#,###').format(result.productPrice);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.kSpaceSm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.kCardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: result.imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                placeholder: (_, __) => Container(
                  height: 120,
                  color: AppColors.kCategoryBg,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.kCategoryBg,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.kDetailSubText,
                  ),
                ),
              )
            else
              Container(
                height: 120,
                color: AppColors.kCategoryBg,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.kDetailSubText,
                ),
              ),
            Container(
              color: AppColors.kWhite,
              padding: const EdgeInsets.all(AppSizes.kSpaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.productName,
                    style: const TextStyle(
                      fontSize: AppSizes.kFontXs,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$priceText원',
                    style: const TextStyle(
                      fontSize: AppSizes.kFontXs,
                      color: AppColors.kDetailSubText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    if (RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
