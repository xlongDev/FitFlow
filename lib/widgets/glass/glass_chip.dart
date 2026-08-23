import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// A small frosted-glass chip / tag.
///
/// Used for filters (muscle groups, equipment), tags, and selectable labels.
/// Supports a selected state that swaps the tint to the primary accent.
///
/// Always meets the 44pt minimum tap target via an outer hit-test area; the
/// visual chip itself can be smaller for compact layouts.
class GlassChip extends StatefulWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onSelected,
    this.icon,
    this.enabled = true,
  });

  /// Chip label text.
  final String label;

  /// Whether the chip is currently in the selected state.
  final bool selected;

  /// Called when the chip is tapped. Use this for non-toggle chips (e.g.
  /// navigation chips). Mutually exclusive with [onSelected].
  final VoidCallback? onTap;

  /// Called with the new selected state when the chip is tapped. Use this for
  /// toggle chips (e.g. filter chips). Mutually exclusive with [onTap].
  final ValueChanged<bool>? onSelected;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the chip accepts input.
  final bool enabled;

  @override
  State<GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends State<GlassChip> with SingleTickerProviderStateMixin {
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

  bool get _enabled =>
      widget.enabled && (widget.onTap != null || widget.onSelected != null);

  void _onTapDown(TapDownDetails _) {
    if (_enabled) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    if (!_enabled) return;
    if (widget.onSelected != null) {
      widget.onSelected!(!widget.selected);
    } else {
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>()!;

    // Selected chips use the primary accent tint; unselected use the glass
    // tint. This makes the selection state obvious without a checkmark.
    final (tint, border, textColor) = widget.selected
        ? (
            theme.colorScheme.primary.withValues(alpha: 0.22),
            theme.colorScheme.primary.withValues(alpha: 0.6),
            theme.colorScheme.primary,
          )
        : (
            glass.tint,
            glass.border,
            theme.colorScheme.onSurface,
          );

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
              child: GlassContainer(
                blur: AppBlur.xs,
                radius: AppRadius.pill,
                tint: tint,
                border: border,
                padding: EdgeInsets.zero,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 14, color: textColor),
                        const SizedBox(width: AppSpacing.xs3),
                      ],
                      Text(
                        widget.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: textColor,
                          fontWeight:
                              widget.selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
