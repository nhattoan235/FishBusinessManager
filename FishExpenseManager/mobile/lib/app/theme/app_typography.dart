import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTypography định nghĩa cỡ chữ theo tiêu chuẩn người lớn tuổi (05_UI_UX_Design.md)
/// Không dùng chữ nhỏ hơn 16sp.
abstract class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
