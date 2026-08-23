/// Blur sigma values for the Liquid Glass effect.
///
/// `BackdropFilter` takes a `sigmaX` / `sigmaY` (gaussian blur standard
/// deviation in pixels). Higher = more frosted. The values here are tuned
/// for the Apple Liquid Glass aesthetic: enough blur to feel "glassy" without
/// making text unreadable.
///
/// ```
/// BackdropFilter(
///   filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
///   ...
/// )
/// ```
class AppBlur {
  AppBlur._();

  /// 8 — subtle blur, used for small chips / overlays.
  static const double xs = 8;

  /// 12 — light blur, used for navigation bars.
  static const double sm = 12;

  /// 18 — medium blur, the default for [GlassCard].
  static const double md = 18;

  /// 24 — strong blur, used for prominent glass surfaces.
  static const double lg = 24;

  /// 30 — heavy blur, used for full-screen overlays / dialogs.
  static const double xl = 30;

  /// 40 — maximum blur, used for the most prominent hero glass surfaces.
  static const double xl2 = 40;
}
