import 'package:flutter/material.dart';

/// AppColors định nghĩa bảng màu theo thiết kế UI/UX (05_UI_UX_Design.md)
abstract class AppColors {
  // Brand / Theme Colors (Material 3 Teal/Emerald tailored for Fish Business)
  static const Color primary = Color(0xFF0F766E); // Teal primary
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);
  
  // Income (Thu) — Màu xanh lá
  static const Color income = Color(0xFF2E7D32);
  static const Color success = income; // Alias for success
  static const Color incomeBackground = Color(0xFFE8F5E9);
  
  // Expense (Chi) — Màu đỏ
  static const Color expense = Color(0xFFC62828);
  static const Color error = expense; // Alias for error
  static const Color expenseBackground = Color(0xFFFFEBEE);

  // Warning (Cảnh báo) — Màu cam
  static const Color warning = Color(0xFFF57C00);
  static const Color warningBackground = Color(0xFFFFE0B2);

  // Info — Màu xanh dương
  static const Color info = Color(0xFF0288D1);
  static const Color infoBackground = Color(0xFFE1F5FE);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
}
