import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.kWhite,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: overlayStyleFor(AppColors.kWhite),
    ),
  );

  static SystemUiOverlayStyle get defaultOverlayStyle =>
      overlayStyleFor(AppColors.kWhite);

  static SystemUiOverlayStyle overlayStyleFor(Color background) {
    final isDark =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}
