// lib/core/theme/app_colors.dart
import 'dart:ui';

class AppColors {
  AppColors._();

  // ── Brand Greens ──────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32); // Deep Forest Green
  static const Color primaryLight = Color(0xFF4CAF50); // Fresh Green
  static const Color primaryBright = Color(0xFF66BB6A); // Soft Green
  static const Color accent = Color(0xFF00C853); // Electric Lime-Green

  // ── Surface & Background ──────────────────────────────
  // Light mode
  static const Color backgroundLight = Color(0xFFF1F8F1); // Barely-green white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFE8F5E9); // Mint card bg
  static const Color pureWhite = Color(0xFFFFFFFF); // pure white

  // Dark mode
  static const Color backgroundDark = Color(0xFF0A1A0A); // Deep forest night
  static const Color surfaceDark = Color(0xFF122312); // Rich dark green
  static const Color cardDark = Color(0xFF1B3A1B); // Elevated card

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1B2E1B);
  static const Color textSecondaryLight = Color(0xFF4A6741);
  static const Color textPrimaryDark = Color(0xFFE8F5E9);
  static const Color textSecondaryDark = Color(0xFFA5C8A5);

  // ── Semantic ──────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF0288D1);

  // ── Divider / Border ──────────────────────────────────
  static const Color dividerLight = Color(0xFFC8E6C9);
  static const Color dividerDark = Color(0xFF2E4D2E);
}
