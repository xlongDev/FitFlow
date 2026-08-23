import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'glass_container.dart';

/// A Liquid Glass segmented control (iOS-style segmented picker).
///
/// Renders a frosted-glass track with N segments. The selected segment slides
/// a highlight pill behind it with a spring animation. Use this for choosing
/// between a small fixed set of mutually-exclusive options (e.g. Grid / List
/// view toggle, Week / Month calendar scope).
///
/// For more than 4-5 options, use a [GlassChip] row or a bottom sheet instead
/// — segmented controls get cramped with long labels.
class GlassSegmentedControl<T> extends StatefulWidget {
  const GlassSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  /// The list of segments to display. Each segment has a label and an
  /// associated value of type [T].
  final List<GlassSegment<T>> segments;

  /// The currently selected value. Must match one of the [segments]' values.
  final T value;

  /// Called when the user selects a different segment.
  final ValueChanged<T> onChanged;

  @override
  State<GlassSegmentedControl<T>> createState() =>
      _GlassSegmentedControlState<T>();
}

/// A single segment in a [GlassSegmentedControl].
class GlassSegment<T> {
  const GlassSegment({required this.label, required this.value, this.icon});

  /// The segment's display label.
  final String label;

  /// The segment's value.
  final T value;

  /// Optional leading icon.
  final IconData? icon;
}

class _GlassSegmentedControlState<T>
    extends State<GlassSegmentedControl<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>()!;

    return GlassContainer(
      blur: AppBlur.sm,
      radius: AppRadius.pill,
      tint: glass.tint,
      border: glass.border,
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Each segment gets an equal share of the track width.
          final segmentWidth =
              (constraints.maxWidth - 8) / widget.segments.length;

          return SizedBox(
            height: 36,
            child: Stack(
              children: [
                // The sliding highlight pill.
                AnimatedAlign(
                  duration: AppAnimation.durationSm,
                  curve: AppAnimation.easeInOut,
                  alignment: _alignmentForValue(),
                  child: Container(
                    width: segmentWidth,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: AppRadius.pillAll,
                      boxShadow: AppShadows.primaryGlow,
                    ),
                  ),
                ),
                // The segment labels, laid out in a row on top of the pill.
                Row(
                  children: widget.segments.map((segment) {
                    final isSelected = segment.value == widget.value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onChanged(segment.value),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (segment.icon != null) ...[
                                Icon(
                                  segment.icon,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                                const SizedBox(width: AppSpacing.xs3),
                              ],
                              Text(
                                segment.label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Maps the selected segment's index to an [Alignment] so [AnimatedAlign]
  /// can slide the highlight pill.
  Alignment _alignmentForValue() {
    final index = widget.segments.indexWhere((s) => s.value == widget.value);
    if (index < 0) return Alignment.centerLeft;
    final count = widget.segments.length;
    // Evenly distribute: index 0 → left, last → right, middle → center.
    final t = count == 1 ? 0.0 : index / (count - 1);
    return Alignment(-1.0 + 2.0 * t, 0.0);
  }
}
