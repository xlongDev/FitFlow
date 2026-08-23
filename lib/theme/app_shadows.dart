import 'package:flutter/material.dart';

/// Shadow definitions for the Liquid Glass depth system.
///
/// Liquid Glass relies on soft, layered shadows to convey depth without the
/// harsh drop shadows typical of Material Design. Each shadow here is a
/// stack of 2-3 [BoxShadow]s with low opacity and large blur radii.
///
/// Usage:
/// ```
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppShadows.glassCard(context),
///     ...
///   ),
/// )
/// ```
class AppShadows {
  AppShadows._();

  /// Soft shadow for standard [GlassCard]s.
  ///
  /// Adapts to brightness: in dark mode the shadow is deeper and cooler.
  static List<BoxShadow> glassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _glassCardDark : _glassCardLight;
  }

  /// Elevated shadow for floating glass elements (FABs, bottom sheets).
  static List<BoxShadow> glassElevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _glassElevatedDark : _glassElevatedLight;
  }

  // ---------------------------------------------------------------------------
  // Light theme shadows
  // ---------------------------------------------------------------------------

  static const List<BoxShadow> _glassCardLight = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> _glassElevatedLight = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 28,
      offset: Offset(0, 10),
      spreadRadius: -1, // negative spread creates a subtle inset glow
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Dark theme shadows — deeper, cooler, lower contrast
  // ---------------------------------------------------------------------------

  static const List<BoxShadow> _glassCardDark = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 20,
      offset: Offset(0, 6),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> _glassElevatedDark = [
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 12,
      offset: Offset(0, 5),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Semantic shadows (theme-independent)
  // ---------------------------------------------------------------------------

  /// Glow shadow for the primary accent — used on primary buttons.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x330A84FF), // 20% primary
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];
}
