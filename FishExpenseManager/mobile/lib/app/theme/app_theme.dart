import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData lightTheme({
    double fontScale = 1.0,
    bool useBoldFont = false,
  }) {
    // Helper function to scale font size and optionally bold it
    TextStyle scaleStyle(TextStyle style) {
      return style.copyWith(
        fontSize: (style.fontSize ?? 14) * fontScale,
        fontWeight: useBoldFont ? FontWeight.bold : style.fontWeight,
      );
    }

    // Explicit bold for buttons
    final buttonWeight = useBoldFont ? FontWeight.w900 : FontWeight.bold;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Roboto',

      // Typography
      textTheme: TextTheme(
        headlineLarge: scaleStyle(AppTypography.displayLarge),
        headlineMedium: scaleStyle(AppTypography.titleLarge),
        titleMedium: scaleStyle(AppTypography.titleMedium),
        bodyLarge: scaleStyle(AppTypography.bodyLarge),
        bodyMedium: scaleStyle(AppTypography.bodyMedium),
        labelLarge: scaleStyle(const TextStyle(fontSize: 14)), // Buttons default
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20 * fontScale,
          fontWeight: buttonWeight,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: buttonWeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: buttonWeight,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.expense),
        ),
        labelStyle: scaleStyle(AppTypography.bodyMedium),
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16 * fontScale),
      ),
    );
  }
}
