import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Typography scale for the app.
///
/// Built on top of the system font (San Francisco on iOS, Roboto on Android)
/// so that Dynamic Type / accessibility text scaling works natively. We do
/// NOT bundle a custom font — the system font is the most accessible choice
/// and matches the Apple aesthetic.
///
/// Sizes follow the iOS type scale (similar to `UIFontTextStyle`).
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Font families
  // ---------------------------------------------------------------------------

  /// The default system font. On iOS this is San Francisco.
  /// `null` means "use the platform default" — the most accessible choice.
  static const String? fontFamily = null;

  // ---------------------------------------------------------------------------
  // Light theme text styles
  // ---------------------------------------------------------------------------

  static const TextTheme lightTextTheme = TextTheme(
    // Display — used for hero numbers / large titles.
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      color: AppColors.textPrimaryLight,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.3,
      color: AppColors.textPrimaryLight,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.textPrimaryLight,
    ),

    // Headline — section titles.
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryLight,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryLight,
    ),

    // Title — card titles, list item titles.
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimaryLight,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textSecondaryLight,
    ),

    // Body — default reading text.
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textPrimaryLight,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textSecondaryLight,
    ),

    // Label — buttons, chips, captions.
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: AppColors.textSecondaryLight,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.2,
      color: AppColors.textTertiaryLight,
    ),
  );

  // ---------------------------------------------------------------------------
  // Dark theme text styles
  // ---------------------------------------------------------------------------

  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.3,
      color: AppColors.textPrimaryDark,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.textPrimaryDark,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textSecondaryDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textPrimaryDark,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: AppColors.textSecondaryDark,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.2,
      color: AppColors.textTertiaryDark,
    ),
  );

  // ---------------------------------------------------------------------------
  // Status bar style helpers
  // ---------------------------------------------------------------------------

  /// Light status bar (dark icons) — used on light backgrounds.
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS
  );

  /// Dark status bar (light icons) — used on dark backgrounds.
  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS
  );
}
