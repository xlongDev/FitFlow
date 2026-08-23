import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
///
/// All colors used anywhere in the UI MUST come from this class (or from the
/// [ThemeData] extensions built on top of it). Hard-coding `Color(0xFF...)`
/// inside widgets is forbidden — it makes theming changes and dark-mode
/// support impossible to audit.
///
/// The palette is tuned for the Liquid Glass design language:
///   * Neutral, slightly cool backgrounds that read as "frosted glass".
///   * A single vivid accent (iOS-style blue) used sparingly.
///   * Translucent surface tints used by [GlassCard] and friends.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand accent
  // ---------------------------------------------------------------------------

  /// Primary accent — iOS system blue. Used for CTAs, active states, links.
  static const Color primary = Color(0xFF0A84FF);

  /// Secondary accent — a warm coral used for highlights / "favorite" states.
  static const Color secondary = Color(0xFFFF6B6B);

  /// Tertiary accent — mint green used for success / progress.
  static const Color tertiary = Color(0xFF30D158);

  // ---------------------------------------------------------------------------
  // Light theme surfaces
  // ---------------------------------------------------------------------------

  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTranslucent = Color(0xCCFFFFFF);

  // ---------------------------------------------------------------------------
  // Dark theme surfaces
  // ---------------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceTranslucent = Color(0xCC1C1C1E);

  // ---------------------------------------------------------------------------
  // Glass tints — overlaid on top of blurred backgrounds.
  // Alpha is intentionally low so the blur shows through.
  // ---------------------------------------------------------------------------

  /// White tint for glass surfaces in light mode.
  static const Color glassTintLight = Color(0x33FFFFFF); // ~20% white

  /// Dark tint for glass surfaces in dark mode — slightly darker than light
  /// so the glass reads as a distinct layer on a dark background.
  static const Color glassTintDark = Color(0x1AFFFFFF); // ~10% white

  /// Border color for glass edges in light mode.
  static const Color glassBorderLight = Color(0x44FFFFFF); // ~27% white

  /// Border color for glass edges in dark mode.
  static const Color glassBorderDark = Color(0x22FFFFFF); // ~13% white

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textTertiaryLight = Color(0xFF8E8E93);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFF8E8E93);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFFD60A);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF0A84FF);

  // ---------------------------------------------------------------------------
  // Separators
  // ---------------------------------------------------------------------------

  static const Color separatorLight = Color(0xFFC6C6C8);
  static const Color separatorDark = Color(0xFF38383A);
}
