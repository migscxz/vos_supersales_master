import 'package:flutter/material.dart';

class AppColors {
  static const textFill = Color(0xFF3E4756);
  static const background = Color(0xFFF0F0F0);
  static const primary = Color(0xFF155E98);
  static const secondary = Color(0xFFDCF2FF);
  static const grey = Color(0xFFB9B9B9);
  static const accent = Color(0xFF5A90CF);
  static const accentBlack = Color(0xFF2C3034);
  static const darkAccent = Color(0xFF2E578F);
  static const steelBlue = Color(0xFFB0BEC5);
}

class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textFill),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textFill,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.accentBlack),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
