import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme extension that exposes Liquid Glass-specific properties.
///
/// Standard [ThemeData] doesn't have fields for glass tint / border colors,
/// so we register them here and access them via:
///
/// ```
/// final glass = Theme.of(context).extension<GlassTheme>()!;
/// glass.tint
/// glass.border
/// ```
///
/// This keeps the glass design system theme-aware (light/dark) without
/// scattering `if (isDark)` checks across the widget tree.
@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.tint,
    required this.border,
    required this.highlight,
  });

  /// Semi-transparent fill color applied on top of the blurred background.
  final Color tint;

  /// Subtle border color for the glass edge.
  final Color border;

  /// Inner highlight color (top edge) that gives the glass a "lit" feel.
  final Color highlight;

  // ---------------------------------------------------------------------------
  // Factory presets
  // ---------------------------------------------------------------------------

  static const GlassTheme light = GlassTheme(
    tint: AppColors.glassTintLight,
    border: AppColors.glassBorderLight,
    highlight: Color(0x55FFFFFF), // ~33% white
  );

  static const GlassTheme dark = GlassTheme(
    tint: AppColors.glassTintDark,
    border: AppColors.glassBorderDark,
    highlight: Color(0x33FFFFFF), // ~20% white
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension contract
  // ---------------------------------------------------------------------------

  @override
  GlassTheme copyWith({
    Color? tint,
    Color? border,
    Color? highlight,
  }) {
    return GlassTheme(
      tint: tint ?? this.tint,
      border: border ?? this.border,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  GlassTheme lerp(GlassTheme? other, double t) {
    if (other == null) return this;
    return GlassTheme(
      tint: Color.lerp(tint, other.tint, t)!,
      border: Color.lerp(border, other.border, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}
