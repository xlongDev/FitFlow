import 'package:flutter/material.dart';

/// Border-radius scale.
///
/// Liquid Glass UI favors large, soft radii. Every corner radius in the app
/// MUST come from here so the visual language stays consistent.
///
/// ```
/// BorderRadius.circular(AppRadius.large) // 24
/// ```
class AppRadius {
  AppRadius._();

  /// 8 — small radius, used for chips / tags / small buttons.
  static const double xs = 8;

  /// 12 — medium-small radius, used for inputs / small cards.
  static const double sm = 12;

  /// 16 — medium radius, used for standard cards.
  static const double md = 16;

  /// 20 — medium-large radius, used for prominent cards.
  static const double lg = 20;

  /// 24 — large radius, the default for [GlassCard].
  static const double xl = 24;

  /// 28 — extra-large radius, used for bottom sheets / dialogs.
  static const double xl2 = 28;

  /// 32 — huge radius, used for full-screen sheets.
  static const double xl3 = 32;

  /// 9999 — fully circular (pills, avatars).
  static const double pill = 9999;

  // ---------------------------------------------------------------------------
  // Pre-built BorderRadius objects
  // ---------------------------------------------------------------------------

  static final BorderRadius xsAll = BorderRadius.circular(xs);
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xl2All = BorderRadius.circular(xl2);
  static final BorderRadius xl3All = BorderRadius.circular(xl3);
  static final BorderRadius pillAll = BorderRadius.circular(pill);
}
