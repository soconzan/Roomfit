import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';
import 'package:roomfit_client/features/product/domain/entities/create_product_params.dart';
import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/features/product/presentation/widgets/product_form_widgets.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({super.key, this.initialPhotos});

  final List<LabeledPhoto>? initialPhotos;

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();
  final _heightController = TextEditingController();
  final _materialController = TextEditingController();

  Category? _selectedCategory;
  int _price = 0;
  final List<XFile> _imageBytes = [];
  final List<LabeledPhoto> _modelImages = [];
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  bool get _canSubmit {
    return !_isSubmitting &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _descriptionController.text.trim().isNotEmpty &&
        _price > 0 &&
        _widthController.text.trim().isNotEmpty &&
        _depthController.text.trim().isNotEmpty &&
        _heightController.text.trim().isNotEmpty &&
        _materialController.text.trim().isNotEmpty &&
        _imageBytes.isNotEmpty &&
        _modelImages.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _priceController.addListener(() {
      final digits = _priceController.text.replaceAll(',', '');
      _price = int.tryParse(digits) ?? 0;
      setState(() {});
    });
    for (final c in [
      _titleController,
      _descriptionController,
      _widthController,
      _depthController,
      _heightController,
      _materialController,
    ]) {
      c.addListener(() => setState(() {}));
    }
    if (widget.initialPhotos != null) {
      _modelImages.addAll(widget.initialPhotos!);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      final userId = await ref.read(authProvider.notifier).getUserId() ?? '';
      await ref
          .read(createProductUseCaseProvider)
          .call(
            CreateProductParams(
              userId: userId,
              productName: _titleController.text.trim(),
              productPrice: _price,
              categoryId: _selectedCategory!.categoryId,
              description: _descriptionController.text.trim(),
              productWidth: (double.tryParse(_widthController.text) ?? 0) * 10,
              productDepth: (double.tryParse(_depthController.text) ?? 0) * 10,
              productHeight:
                  (double.tryParse(_heightController.text) ?? 0) * 10,
              productMaterial: _materialController.text.trim(),
              images: _imageBytes,
              modelImages: _modelImages,
            ),
          );
      if (mounted) context.canPop() ? context.pop() : context.go(AppPaths.home);
    } catch (e) {
      debugPrint('[createProduct] error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    _heightController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final int currentCount = _imageBytes.length;
    if (_imageBytes.length >= 10) return;
    final picked = await _picker.pickMultiImage(limit: 10 - currentCount);
    if (picked.isEmpty) return;
    setState(() {
      final remaining = 10 - _imageBytes.length;
      _imageBytes.addAll(picked.take(remaining));
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final image = _imageBytes.removeAt(oldIndex);
      _imageBytes.insert(newIndex, image);
    });
  }

  void _removeImage(int index) {
    setState(() => _imageBytes.removeAt(index));
  }

  void _showCategorySheet() {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
      ),
      builder: (sheetContext) {
        return Padding(
          // padding: const EdgeInsets.all(AppSizes.kSpaceLg),
          padding: const EdgeInsetsGeometry.only(top: AppSizes.kSpaceXl),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSizes.kSpaceXs,
                ),
                title: Text(
                  category.categoryName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Navigator.pop(sheetContext);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면 진입 시 카테고리를 미리 로드 (시트 열기 전에 준비)
    ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: AppSizes.kSpaceXs,
                  right: AppSizes.kSpaceXl,
                  left: AppSizes.kSpaceXl,
                  bottom: AppSizes.kSpaceXl,
                ),
                // padding: const EdgeInsets.all(AppSizes.kSpaceXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    _buildPhotoSection(),
                    ProductFormTextField(
                      label: AppStrings.kProductCreateLabelTitle,
                      controller: _titleController,
                      hintText: AppStrings.kProductCreateTitleHint,
                    ),
                    _buildCategoryField(),
                    ProductFormTextField(
                      label: AppStrings.kProductCreateLabelDescription,
                      controller: _descriptionController,
                      hintText: AppStrings.kProductCreateDescriptionHint,
                      minLines: 3,
                      maxLines: 8,
                    ),
                    ProductFormTextField(
                      label: AppStrings.kProductCreateLabelPrice,
                      controller: _priceController,
                      hintText: AppStrings.kProductCreatePriceHint,
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.all(10),
                      prefixText: AppStrings.kProductCreatePricePrefix,
                      inputFormatters: [ProductCurrencyFormatter()],
                    ),
                    _buildSizeSection(),
                    ProductFormTextField(
                      label: AppStrings.kProductCreateLabelMaterial,
                      controller: _materialController,
                      hintText: AppStrings.kProductCreateMaterialHint,
                    ),
                    _build3dSection(context),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kSpaceXl,
        vertical: AppSizes.kSpaceMd,
      ),
      child: Row(
        spacing: 5,
        children: [
          GestureDetector(
            onTap:
                () =>
                    context.canPop()
                        ? context.pop()
                        : context.go(AppPaths.home),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.kBlack,
              size: 20,
            ),
          ),
          const Text(
            AppStrings.kProductCreateTitle,
            style: TextStyle(
              color: AppColors.kBlack,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    const cellSize = 90.0;
    const gap = 10.0;

    return SizedBox(
      height: cellSize,
      child: Row(
        children: [
          SizedBox(
            width: cellSize,
            height: cellSize,
            child: _AddPhotoBox(count: _imageBytes.length, onTap: _pickImages),
          ),
          if (_imageBytes.isNotEmpty) ...[
            const SizedBox(width: gap),
            Expanded(
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: _reorderImages,
                children: [
                  for (int i = 0; i < _imageBytes.length; i++)
                    ReorderableDelayedDragStartListener(
                      key: ValueKey(_imageBytes[i].path),
                      index: i,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < _imageBytes.length - 1 ? gap : 0,
                        ),
                        child: SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: _PhotoThumbnail(
                            file: File(_imageBytes[i].path),
                            isFirst: i == 0,
                            onRemove: () => _removeImage(i),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        const Text(
          AppStrings.kProductCreateLabelCategory,
          style: TextStyle(
            color: AppColors.kBlack,
            fontSize: AppSizes.kFontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: _showCategorySheet,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: AppColors.kInputBorder),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory?.categoryName ??
                      AppStrings.kProductCreateCategoryHint,
                  style: TextStyle(
                    color:
                        _selectedCategory != null
                            ? AppColors.kBlack
                            : AppColors.kInputHint,
                    fontSize: AppSizes.kFontSm,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.kInputHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: ProductFormTextField(
            label: AppStrings.kProductCreateLabelWidth,
            controller: _widthController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [ProductDecimalFormatter()],
          ),
        ),
        Expanded(
          child: ProductFormTextField(
            label: AppStrings.kProductCreateLabelDepth,
            controller: _depthController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [ProductDecimalFormatter()],
          ),
        ),
        Expanded(
          child: ProductFormTextField(
            label: AppStrings.kProductCreateLabelHeight,
            controller: _heightController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [ProductDecimalFormatter()],
          ),
        ),
      ],
    );
  }

  Widget _build3dSection(BuildContext context) {
    final isReady = _modelImages.isNotEmpty;
    return Column(
      spacing: 7,
      children: [
        InkWell(
          onTap:
              isReady
                  ? null
                  : () async {
                    final result = await context.push(AppPaths.modelingMethod);
                    if (result is List<LabeledPhoto> && mounted) {
                      setState(() {
                        _modelImages
                          ..clear()
                          ..addAll(result);
                      });
                    }
                  },
          borderRadius: BorderRadius.circular(5),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color:
                  isReady
                      ? AppColors.k3dButtonBg.withAlpha(120)
                      : AppColors.k3dButtonBg,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 11,
              children: [
                Icon(
                  isReady
                      ? Icons.check_circle_rounded
                      : Icons.view_in_ar_rounded,
                  color: AppColors.kWhite,
                  size: 24,
                ),
                Text(
                  isReady
                      ? AppStrings.kProductCreate3dButtonReady
                      : AppStrings.kProductCreate3dButton,
                  style: const TextStyle(
                    color: AppColors.kWhite,
                    fontSize: AppSizes.kFontMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text(
          AppStrings.kProductCreate3dNote,
          style: TextStyle(
            color: AppColors.kNoteText,
            fontSize: AppSizes.kFontXs,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: _canSubmit ? _submit : null,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color:
                _canSubmit
                    ? AppColors.kBlack
                    : const Color.fromARGB(255, 123, 129, 129).withAlpha(168),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Center(
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.kWhite,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      AppStrings.kProductCreateSubmit,
                      style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: AppSizes.kFontLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}


class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.file,
    required this.isFirst,
    required this.onRemove,
  });

  final File file;
  final bool isFirst;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        if (isFirst)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.kBlack.withAlpha(180),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: const Text(
                AppStrings.kProductCreateRepresentative,
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: AppSizes.kFontXs,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.kBlack.withAlpha(180),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: const Icon(Icons.close, color: AppColors.kWhite, size: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoBox extends StatelessWidget {
  const _AddPhotoBox({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: AppColors.kInputBorder),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_gallery_outline.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.kInputHint,
                BlendMode.srcIn,
              ),
            ),
            Text(
              '$count${AppStrings.kProductCreatePhotoSuffix}',
              style: const TextStyle(
                color: AppColors.kInputHint,
                fontSize: AppSizes.kFontXs,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

