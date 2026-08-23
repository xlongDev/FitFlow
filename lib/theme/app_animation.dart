import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Animation duration and curve tokens.
///
/// Apple's motion design favors spring physics for interactive elements and
/// ease-in-out for non-interactive transitions. The durations here are tuned
/// to feel snappy on modern devices (60-120Hz) without being jarring.
///
/// Usage:
/// ```
/// AnimationController(
///   duration: AppAnimation.durationMd,
///   ...
/// )
/// ```
class AppAnimation {
  AppAnimation._();

  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// 150ms — micro interactions (tap feedback, toggle).
  static const Duration durationXs = Duration(milliseconds: 150);

  /// 250ms — standard UI transitions (fade, scale).
  static const Duration durationSm = Duration(milliseconds: 250);

  /// 350ms — the default for most animations.
  static const Duration durationMd = Duration(milliseconds: 350);

  /// 500ms — page transitions, hero animations.
  static const Duration durationLg = Duration(milliseconds: 500);

  /// 700ms — large hero / parallax animations.
  static const Duration durationXl = Duration(milliseconds: 700);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------

  /// iOS-style spring for interactive elements (button press, card tap).
  static const Curve spring = Curves.easeOutBack;

  /// Smooth deceleration for entering elements.
  static const Curve easeOut = Curves.easeOutCubic;

  /// Smooth acceleration for exiting elements.
  static const Curve easeIn = Curves.easeInCubic;

  /// Standard ease-in-out for symmetric transitions.
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// Cupertino page transition curve.
  static const Curve cupertino = Curves.linearToEaseOut;

  // ---------------------------------------------------------------------------
  // Spring physics
  // ---------------------------------------------------------------------------

  /// Spring description for the signature GlassCard tap scale animation.
  /// Slightly under-damped for a subtle bounce.
  static final SpringDescription glassCardSpring = SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: 300.0,
    ratio: 0.7,
  );

  // ---------------------------------------------------------------------------
  // Scale factors
  // ---------------------------------------------------------------------------

  /// Scale factor when a [GlassCard] is pressed (1.0 → 0.97 → 1.0).
  static const double pressedScale = 0.97;

  /// Scale factor for favorite button animation.
  static const double favoriteScale = 1.3;

  // ---------------------------------------------------------------------------
  // Stagger helpers
  // ---------------------------------------------------------------------------

  /// Default interval between staggered list items.
  static const Duration staggerInterval = Duration(milliseconds: 50);

  /// Maximum number of items that participate in stagger (avoids long delays
  /// for very long lists).
  static const int maxStaggerItems = 8;
}
