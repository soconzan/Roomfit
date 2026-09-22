import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base
  static const Color kBlack = Color.fromARGB(255, 5, 5, 5);
  static const Color kWhite = Color.fromARGB(255, 255, 255, 255);
  static const Color kGray = Color.fromARGB(255, 134, 134, 135);

  // Bottom Navigation Bar
  static const Color kNavSelected = kBlack;
  static const Color kNavUnselected = Color(0xFFC4C8C7);
  static const Color kNavBarBg = Color(0x80FFFFFF); // 50% 불투명 흰색

  // Home
  static const Color kFabShadow = Color(0x26000000);

  // Form / Input
  static const Color kInputBorder = Color(0xFFBEBEBE);
  static const Color kInputHint = Color(0xFF818181);

  // Product List
  static const Color kSubText = Color(0xFF6F7E7A);

  // Product Create
  static const Color k3dButtonBg = Color.fromARGB(255, 124, 216, 255);
  static const Color kNoteText = Color(0xFF767676);

  // Auth
  static const Color kAuthTitle = Color(0xFF141419);
  static const Color kAuthLabel = Color(0xFF3F3F4C);
  static const Color kAuthFieldBg = Color.fromARGB(255, 246, 246, 248);
  static const Color kAuthFieldBorder = Color(0xFFE0E4E5);
  static const Color kAuthHint = Color(0xFFB7C1C1);
  static const Color kAuthButtonShadow = Color.fromARGB(74, 87, 95, 96);

  // Product Detail
  static const Color kDetailDescText = Color(0xFF363A39);
  static const Color kDetailSubText = Color(0xFF89918F);
  static const Color kDetailDividerLine = Color(0xFFEDF2F0);
  static const Color kDetailMenuBg = Color(0xFFF9FAFA);
  static const Color kDetailMenuDivider = Color(0xFFCFDBDB);
  static const Color kDetailMenuBarrier = Color(0x4C434A4A);
  static const Color kDetailDeleteRed = Color(0xFFD42B2B);
  static const Color kDetailCounterBg = Color(0x66000000);
  // static const Color kArButton = Color(0xFF2CEDB8);
  // static const Color k3dViewerArText = Color(0xFF07D099);

  // Profile
  static const Color kProfileCardShadow = Color(0x33CDD8D8);
  static const Color kProfileSubText = Color(0xFF748080);
  static const Color kProfileLogoutBg = Color(0xFFD8DCDC);
  static const Color kProfileLogoutText = Color(0xFF737373);

  // Category
  static const Color kCategoryBg = Color(0xFFF9FAFA);

  // Search
  static const Color kSearchItemText = Color(0xFF676A6D);
  static const Color kSearchDivider = Color(0xFFD0D7D5);

  // Modeling
  static const Color kModelingCardBg = Color.fromARGB(255, 248, 250, 251);
  static const Color kModelingCardBorder = Color(0xFFE8EFEC);
  static const Color kModelingSecondaryText = Color(0xFF6F7B78);
  static const Color kModelingPrimaryText = Color(0xFF1D2220);
}
