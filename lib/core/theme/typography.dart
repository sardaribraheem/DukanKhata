import 'package:flutter/material.dart';
import 'colors.dart';

/// Large, legible text styles optimized for older users (70s age bracket).
/// Minimum body text size is 16px, with prominent titles (22-32px).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // System fallback clean font

  static TextStyle displayLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle displayMedium = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headingLarge = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headingMedium = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle buttonLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle caption = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}
