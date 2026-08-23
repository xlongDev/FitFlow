import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// The foundational building block of the Liquid Glass design system.
///
/// [GlassContainer] renders a frosted-glass surface by stacking:
///   1. A [BackdropFilter] that blurs whatever is painted behind it.
///   2. A semi-transparent tint fill (read from [GlassTheme]).
///   3. A subtle border on the glass edge.
///   4. A soft layered shadow for depth.
///
/// Every other Glass component ([GlassCard], [GlassButton], …) composes a
/// [GlassContainer] rather than calling `BackdropFilter` directly — this is
/// the single place where the blur / tint / border / shadow recipe lives,
/// so the visual language stays consistent and theme-aware.
///
/// The container itself is non-interactive. For tappable surfaces use
/// [GlassCard]; for buttons use [GlassButton].
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = AppBlur.md,
    this.radius = AppRadius.xl,
    this.elevated = false,
    this.tint,
    this.border,
    this.padding,
    this.margin,
    this.shadow,
  });

  /// The content painted on top of the frosted glass.
  final Widget child;

  /// Gaussian blur sigma. Defaults to [AppBlur.md] (18) — the signature
  /// Liquid Glass look. Increase for prominent hero surfaces.
  final double blur;

  /// Corner radius. Defaults to [AppRadius.xl] (24).
  final double radius;

  /// When `true`, uses the elevated shadow stack (for FABs, sheets).
  final bool elevated;

  /// Override the glass tint. When `null`, reads from [GlassTheme] so the
  /// surface adapts to light / dark mode automatically.
  final Color? tint;

  /// Override the glass border color. When `null`, reads from [GlassTheme].
  final Color? border;

  /// Internal padding around [child].
  final EdgeInsetsGeometry? padding;

  /// External margin around the glass surface.
  final EdgeInsetsGeometry? margin;

  /// Override the shadow stack. When `null`, picks the standard or elevated
  /// stack based on [elevated].
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final effectiveTint = tint ?? glass.tint;
    final effectiveBorder = border ?? glass.border;
    final effectiveShadow = shadow ??
        (elevated
            ? AppShadows.glassElevated(context)
            : AppShadows.glassCard(context));

    final decoration = BoxDecoration(
      color: effectiveTint,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: effectiveBorder),
      boxShadow: effectiveShadow,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        // Clip is needed so the BackdropFilter's blur is constrained to the
        // rounded rectangle — without it the blur would bleed past the edges.
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: decoration,
            child: padding == null ? child : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}
