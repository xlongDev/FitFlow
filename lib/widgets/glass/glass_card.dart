import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// A tappable frosted-glass surface.
///
/// [GlassCard] wraps [GlassContainer] and adds:
///   * A Cupertino-style press scale animation (1.0 → 0.97 → 1.0) that makes
///     the card feel physically responsive without being flashy.
///   * Optional `onTap` / `onLongPress` callbacks.
///   * A subtle highlight overlay on press for extra tactile feedback.
///
/// Use this for any tappable content surface: exercise cards, plan cards,
/// stat tiles, etc. For non-interactive frosted surfaces use [GlassContainer]
/// directly; for primary actions use [GlassButton].
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.blur = AppBlur.md,
    this.radius = AppRadius.xl,
    this.elevated = false,
    this.padding = AppSpacing.cardPadding,
    this.margin,
  });

  /// The content inside the card.
  final Widget child;

  /// Called when the user taps the card. When `null`, the card is
  /// non-interactive (no press animation, no hover).
  final VoidCallback? onTap;

  /// Called when the user long-presses the card.
  final VoidCallback? onLongPress;

  /// Blur sigma forwarded to [GlassContainer].
  final double blur;

  /// Corner radius forwarded to [GlassContainer].
  final double radius;

  /// Whether to use the elevated shadow stack.
  final bool elevated;

  /// Internal padding. Defaults to [AppSpacing.cardPadding].
  final EdgeInsetsGeometry padding;

  /// External margin.
  final EdgeInsetsGeometry? margin;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    // A spring controller gives a more natural press feel than a plain
    // CurvedAnimation — the slight overshoot reads as "physical".
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimation.durationXs,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimation.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnimation.easeInOut));
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimation.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _onTapDown(TapDownDetails _) {
    if (_interactive) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onLongPress() {
    _controller.reverse();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    // When the card isn't interactive we skip the animation tree entirely —
    // this keeps non-tappable cards cheap and avoids an unnecessary
    // AnimationController per card in long lists.
    if (!_interactive) {
      return GlassContainer(
        blur: widget.blur,
        radius: widget.radius,
        elevated: widget.elevated,
        padding: widget.padding,
        margin: widget.margin,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: _onLongPress,
      // Cupertino-style tap target: never smaller than 44pt.
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              blur: widget.blur,
              radius: widget.radius,
              elevated: widget.elevated,
              padding: widget.padding,
              margin: widget.margin,
              child: Stack(
                children: [
                  widget.child,
                  // A white highlight wash that fades in on press — gives
                  // the glass a "lit from within" tactile feel.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.radius),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.08 * _highlightAnimation.value,
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
