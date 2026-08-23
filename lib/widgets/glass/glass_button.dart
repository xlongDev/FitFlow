import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// Visual style of a [GlassButton].
enum GlassButtonStyle {
  /// Solid primary-accent fill with white text — the main call-to-action.
  primary,

  /// Frosted glass with a primary-accent border — secondary actions.
  secondary,

  /// Translucent glass with no strong accent — tertiary / destructive-adjacent
  /// actions. Use [GlassButtonStyle.destructive] for actual destructive
  /// actions.
  text,

  /// Red-tinted glass — delete / remove actions.
  destructive,
}

/// A Liquid Glass button.
///
/// Renders as a frosted-glass pill (or rounded rectangle) with a press-scale
/// animation. The [style] controls the accent treatment:
///
///   * [GlassButtonStyle.primary] — solid accent fill, white text. Use for the
///     single most important action on a screen.
///   * [GlassButtonStyle.secondary] — glass with accent border. Use for
///     supporting actions.
///   * [GlassButtonStyle.text] — plain glass. Use for low-emphasis actions.
///   * [GlassButtonStyle.destructive] — red glass. Use for delete / remove.
///
/// Buttons expand to fill their parent's width when [expanded] is `true`;
/// otherwise they size to their content. Always respects the 44pt minimum tap
/// target for accessibility.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = GlassButtonStyle.primary,
    this.icon,
    this.expanded = false,
    this.enabled = true,
    this.radius = AppRadius.xl,
  });

  /// Button label text.
  final String label;

  /// Called when the user taps the button. When `null` or when [enabled] is
  /// `false`, the button is disabled (greyed out, no press animation).
  final VoidCallback? onPressed;

  /// Visual style.
  final GlassButtonStyle style;

  /// Optional leading icon.
  final IconData? icon;

  /// When `true`, the button fills its parent's width.
  final bool expanded;

  /// Whether the button accepts input.
  final bool enabled;

  /// Corner radius. Defaults to [AppRadius.xl] (24).
  final double radius;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimation.durationXs,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimation.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnimation.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.enabled && widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (_enabled) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    if (_enabled) widget.onPressed!();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (fillColor, textColor, borderColor) = _resolveColors(theme, isDark);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _enabled ? 1.0 : 0.45,
              child: _buildSurface(
                context: context,
                fillColor: fillColor,
                borderColor: borderColor,
                textColor: textColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurface({
    required BuildContext context,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    final useGlassFill = widget.style != GlassButtonStyle.primary;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    // The minimum tap target is 44pt — enforce it via a ConstrainedBox so
    // short labels still meet accessibility guidelines.
    final padded = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: content,
    );

    if (!useGlassFill) {
      // Primary: solid accent fill, no blur (no glass behind it needed).
      return DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: AppShadows.primaryGlow,
        ),
        child: padded,
      );
    }

    // Secondary / text / destructive: frosted glass with optional border.
    return GlassContainer(
      blur: AppBlur.sm,
      radius: widget.radius,
      tint: fillColor,
      border: borderColor,
      padding: EdgeInsets.zero,
      child: padded,
    );
  }

  /// Resolves (fill, text, border) colors for the current [widget.style].
  ///
  /// Kept as a single method so the color logic is auditable in one place —
  /// adding a new style only requires extending this switch.
  (Color, Color, Color) _resolveColors(ThemeData theme, bool isDark) {
    final glass = theme.extension<GlassTheme>()!;
    switch (widget.style) {
      case GlassButtonStyle.primary:
        return (
          theme.colorScheme.primary,
          Colors.white,
          Colors.transparent,
        );
      case GlassButtonStyle.secondary:
        return (
          glass.tint,
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.4),
        );
      case GlassButtonStyle.text:
        return (
          glass.tint,
          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          glass.border,
        );
      case GlassButtonStyle.destructive:
        return (
          AppColors.error.withValues(alpha: 0.18),
          AppColors.error,
          AppColors.error.withValues(alpha: 0.4),
        );
    }
  }
}
