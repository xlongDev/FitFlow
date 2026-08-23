import 'package:flutter/material.dart';

/// Spacing scale used across the entire app.
///
/// Built on a 4pt grid (the de-facto standard for mobile UI). Every padding,
/// margin, gap, and inset MUST reference one of these tokens so the visual
/// rhythm stays consistent and dark-mode / density tweaks are centralized.
///
/// ```
/// Padding.all(AppSpacing.md)   // 16
/// SizedBox(height: AppSpacing.xs) // 8
/// ```
class AppSpacing {
  AppSpacing._();

  /// 4 — hairline spacing, used between tightly grouped elements.
  static const double xs3 = 4;

  /// 8 — small spacing, used inside cards / chips.
  static const double xs = 8;

  /// 12 — small-medium spacing.
  static const double sm = 12;

  /// 16 — the default content padding.
  static const double md = 16;

  /// 20 — medium-large spacing, used between sections.
  static const double lg = 20;

  /// 24 — large spacing, used between major sections.
  static const double xl = 24;

  /// 32 — extra-large spacing, used for page-level gaps.
  static const double xl2 = 32;

  /// 48 — huge spacing, used for hero / empty-state gaps.
  static const double xl3 = 48;

  /// 64 — maximum spacing, used for full-screen empty states.
  static const double xl4 = 64;

  // ---------------------------------------------------------------------------
  // Screen-level insets
  // ---------------------------------------------------------------------------

  /// Horizontal padding applied to page content.
  static const double pageHorizontal = 20;

  /// Vertical padding applied to page content.
  static const double pageVertical = 16;

  /// Standard page content padding (horizontal + vertical).
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  /// Card internal padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}
