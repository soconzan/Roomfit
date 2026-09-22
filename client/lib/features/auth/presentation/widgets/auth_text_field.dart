import 'package:flutter/material.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';

/// 중복 확인 상태
enum CheckStatus { idle, loading, success, failure }

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.errorText,
    this.checkStatus = CheckStatus.idle,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorText;
  final CheckStatus checkStatus;

  static final _border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(10),
  );

  static final _errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 1, color: Colors.red),
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    Widget? suffixIcon;
    switch (checkStatus) {
      case CheckStatus.loading:
        suffixIcon = const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.kAuthHint,
            ),
          ),
        );
      case CheckStatus.success:
        suffixIcon = const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 20,
        );
      case CheckStatus.failure:
        suffixIcon = const Icon(
          Icons.cancel_rounded,
          color: Colors.red,
          size: 20,
        );
      case CheckStatus.idle:
        suffixIcon = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kAuthLabel,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: AppColors.kAuthTitle,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.kAuthHint,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.kAuthFieldBg,
            contentPadding: const EdgeInsets.all(23),
            border: hasError ? _errorBorder : _border,
            enabledBorder: hasError ? _errorBorder : _border,
            focusedBorder: hasError ? _errorBorder : _border,
            suffixIcon: suffixIcon,
          ),
        ),
        if (hasError)
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
