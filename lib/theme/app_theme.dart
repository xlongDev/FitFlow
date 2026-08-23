import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'glass_theme.dart';

/// Centralized [ThemeData] for the app.
///
/// Produces both light and dark themes. The design is Cupertino-leaning
/// (Apple Liquid Glass aesthetic) but uses Material [ThemeData] as the
/// transport so that standard Flutter widgets pick up the right colors.
///
/// Glass-specific tokens are registered as a [GlassTheme] extension so
/// widgets can read them via `Theme.of(context).extension<GlassTheme>()`.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
    );

    return _baseTheme(colorScheme, Brightness.light).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        barBackgroundColor: AppColors.lightSurfaceTranslucent,
        textTheme: CupertinoTextThemeData(),
      ),
      extensions: [
        GlassTheme.light,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.darkSurface,
    );

    return _baseTheme(colorScheme, Brightness.dark).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        barBackgroundColor: AppColors.darkSurfaceTranslucent,
        textTheme: CupertinoTextThemeData(),
      ),
      extensions: [
        GlassTheme.dark,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared base
  // ---------------------------------------------------------------------------

  static ThemeData _baseTheme(ColorScheme colorScheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textTheme = isLight
        ? AppTypography.lightTextTheme
        : AppTypography.darkTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // Disable the default Material visual density to get a tighter,
      // Apple-like layout.
      visualDensity: VisualDensity.standard,
      // Animations
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // Page transitions — Cupertino spring by default.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
      // Remove the default Material AppBar — we use Glass/Cupertino bars.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(
          color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        ),
      ),
      // Buttons — we use custom Glass buttons, but configure defaults so
      // any stray Material buttons still look acceptable.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0x0D000000) // 5% black
            : const Color(0x1AFFFFFF), // 10% white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.separatorLight : AppColors.separatorDark,
        thickness: 0.5,
        space: 0.5,
      ),
      // Icon theme
      iconTheme: IconThemeData(
        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        size: 22,
      ),
    );
  }
}
