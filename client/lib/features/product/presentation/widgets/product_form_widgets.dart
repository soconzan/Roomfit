import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';

class ProductFormTextField extends StatelessWidget {
  const ProductFormTextField({
    super.key,
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

class ProductCurrencyFormatter extends TextInputFormatter {
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

class ProductDecimalFormatter extends TextInputFormatter {
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
