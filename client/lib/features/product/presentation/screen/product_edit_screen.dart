import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/features/category/domain/entities/category.dart';
import 'package:roomfit_client/features/category/presentation/provider/category_provider.dart';
import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';
import 'package:roomfit_client/features/product/domain/entities/product_detail.dart';
import 'package:roomfit_client/features/product/domain/entities/update_product_params.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/core/router/app_router.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({
    super.key,
    required this.productId,
    required this.detail,
  });

  final int productId;
  final ProductDetail detail;

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();
  final _heightController = TextEditingController();
  final _materialController = TextEditingController();

  Category? _selectedCategory;
  int _price = 0;
  final List<LabeledPhoto> _modelImages = [];
  bool _isSubmitting = false;

  static final _fmt = NumberFormat('#,###');

  bool get _canSubmit {
    return !_isSubmitting &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _descriptionController.text.trim().isNotEmpty &&
        _price > 0 &&
        _widthController.text.trim().isNotEmpty &&
        _depthController.text.trim().isNotEmpty &&
        _heightController.text.trim().isNotEmpty &&
        _materialController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.detail;

    _titleController.text = d.productName;
    _descriptionController.text = d.description;
    _materialController.text = d.productMaterial;

    _price = d.productPrice;
    _priceController.text = _fmt.format(d.productPrice);

    _widthController.text = _formatSize(d.productWidth);
    _depthController.text = _formatSize(d.productDepth);
    _heightController.text = _formatSize(d.productHeight);

    _selectedCategory = Category(
      categoryId: d.categoryId,
      categoryName: d.categoryName,
    );

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
  }

  String _formatSize(double mm) {
    final cm = mm / 10;
    return cm % 1 == 0 ? cm.toInt().toString() : cm.toString();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      final userId = await ref.read(authProvider.notifier).getUserId() ?? '';
      await ref.read(updateProductUseCaseProvider).call(
        UpdateProductParams(
          productId: widget.productId,
          userId: userId,
          productName: _titleController.text.trim(),
          productPrice: _price,
          categoryId: _selectedCategory!.categoryId,
          description: _descriptionController.text.trim(),
          productWidth: (double.tryParse(_widthController.text) ?? 0) * 10,
          productDepth: (double.tryParse(_depthController.text) ?? 0) * 10,
          productHeight: (double.tryParse(_heightController.text) ?? 0) * 10,
          productMaterial: _materialController.text.trim(),
          modelImages: _modelImages.isEmpty ? null : _modelImages,
        ),
      );
      if (mounted) {
        ref.invalidate(productDetailProvider(widget.productId));
        context.pop();
      }
    } catch (e) {
      debugPrint('🔴 [ERROR] updateProduct 실패: $e');
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
    ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSizes.kSpaceXs,
                  right: AppSizes.kSpaceXl,
                  left: AppSizes.kSpaceXl,
                  bottom: AppSizes.kSpaceXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    _buildReadOnlyPhotoSection(),
                    _LabeledTextField(
                      label: AppStrings.kProductCreateLabelTitle,
                      controller: _titleController,
                      hintText: AppStrings.kProductCreateTitleHint,
                    ),
                    _buildCategoryField(),
                    _LabeledTextField(
                      label: AppStrings.kProductCreateLabelDescription,
                      controller: _descriptionController,
                      hintText: AppStrings.kProductCreateDescriptionHint,
                      minLines: 3,
                      maxLines: 8,
                    ),
                    _LabeledTextField(
                      label: AppStrings.kProductCreateLabelPrice,
                      controller: _priceController,
                      hintText: AppStrings.kProductCreatePriceHint,
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.all(10),
                      prefixText: AppStrings.kProductCreatePricePrefix,
                      inputFormatters: [_CurrencyInputFormatter()],
                    ),
                    _buildSizeSection(),
                    _LabeledTextField(
                      label: AppStrings.kProductCreateLabelMaterial,
                      controller: _materialController,
                      hintText: AppStrings.kProductCreateMaterialHint,
                    ),
                    _build3dSection(context),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
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
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.kBlack,
              size: 20,
            ),
          ),
          const Text(
            AppStrings.kDetailEditPost,
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

  Widget _buildReadOnlyPhotoSection() {
    const cellSize = 90.0;
    const gap = 10.0;
    final urls = widget.detail.imageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: cellSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: gap),
        itemBuilder: (_, i) {
          return SizedBox(
            width: cellSize,
            height: cellSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: urls[i],
                    fit: BoxFit.cover,
                  ),
                ),
                if (i == 0)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
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
              ],
            ),
          );
        },
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
                    color: _selectedCategory != null
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
          child: _LabeledTextField(
            label: AppStrings.kProductCreateLabelWidth,
            controller: _widthController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [_DecimalInputFormatter()],
          ),
        ),
        Expanded(
          child: _LabeledTextField(
            label: AppStrings.kProductCreateLabelDepth,
            controller: _depthController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [_DecimalInputFormatter()],
          ),
        ),
        Expanded(
          child: _LabeledTextField(
            label: AppStrings.kProductCreateLabelHeight,
            controller: _heightController,
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            contentPadding: const EdgeInsets.all(10),
            suffixText: AppStrings.kProductCreateSizeSuffix,
            inputFormatters: [_DecimalInputFormatter()],
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
          onTap: () async {
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
              color: isReady
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
                      ? AppStrings.kProductEdit3dButtonReady
                      : AppStrings.kProductEdit3dButton,
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

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: _canSubmit ? _submit : null,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _canSubmit
                ? AppColors.kBlack
                : const Color.fromARGB(255, 123, 129, 129).withAlpha(168),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.kWhite,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    AppStrings.kProductEditSubmit,
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

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.contentPadding = const EdgeInsets.all(12),
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final EdgeInsets contentPadding;
  final String? prefixText;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  static const _affixStyle = TextStyle(
    color: AppColors.kInputHint,
    fontSize: AppSizes.kFontSm,
    fontWeight: FontWeight.w300,
  );

  static final _border = OutlineInputBorder(
    borderSide: const BorderSide(width: 0.5, color: AppColors.kInputBorder),
    borderRadius: BorderRadius.circular(5),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kBlack,
            fontSize: AppSizes.kFontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            color: AppColors.kBlack,
            fontSize: AppSizes.kFontMd,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.kInputHint,
              fontSize: AppSizes.kFontMd,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: prefixText != null
                ? Center(
                    widthFactor: 1,
                    child: Text(prefixText!, style: _affixStyle),
                  )
                : null,
            suffixIcon: suffixText != null
                ? Center(
                    widthFactor: 1,
                    child: Text(suffixText!, style: _affixStyle),
                  )
                : null,
            contentPadding: contentPadding,
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border,
          ),
        ),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  static final _fmt = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = _fmt.format(int.parse(digits));
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final filtered = text.replaceAll(RegExp(r'[^0-9.]'), '');
    if ('.'.allMatches(filtered).length > 1) return oldValue;
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
