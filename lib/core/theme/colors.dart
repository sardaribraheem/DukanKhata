import 'package:flutter/material.dart';

/// App color palette designed for high contrast and calm tactile claymorphism.
/// Warm earthy shop tones with clear semantic action colors.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFFF2EFE9); // Warm stone / bone white
  static const Color surface = Color(0xFFFAF7F2); // Slightly raised card surface
  static const Color surfaceRaised = Color(0xFFFFFFFF); // Pure white highlight

  // Text colors (High contrast for older eyes)
  static const Color textPrimary = Color(0xFF1E1E1E); // Deep charcoal (near black)
  static const Color textSecondary = Color(0xFF4A4A4A); // Mid-tone charcoal
  static const Color textMuted = Color(0xFF757575); // Subtle helper text

  // Primary Brand Colors (Shop Trust - Deep Teal / Blue Slate)
  static const Color primary = Color(0xFF0F5A47); // Rich dark emerald / oil dark green
  static const Color primaryLight = Color(0xFF1A8C6F);
  static const Color primaryContainer = Color(0xFFD6F0E6);

  // Semantic & Action Colors
  static const Color sellGreen = Color(0xFF137A3D); // Clear green for recording sales / income
  static const Color sellGreenContainer = Color(0xFFDDF5E6);

  static const Color costRed = Color(0xFFB42318); // Clear brick red for expenses / restock cost
  static const Color costRedContainer = Color(0xFFFEE4E2);

  static const Color micAmber = Color(0xFFB54708); // Warm orange / amber for mic / recording
  static const Color micAmberContainer = Color(0xFFFEF0C7);

  static const Color favoriteGold = Color(0xFFF79009);

  // Claymorphism Shadow & Border Colors
  static const Color clayLightShadow = Color(0xFFFFFFFF);
  static const Color clayDarkShadow = Color(0xFFD0C9BE);
  static const Color clayBorder = Color(0xFFE5DFD5);
}
