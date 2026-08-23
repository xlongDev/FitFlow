import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// A shimmer-style skeleton placeholder.
///
/// Renders a series of grey rounded rectangles that pulse to indicate
/// loading. Used by the exercise library while the database query runs.
///
/// The shimmer effect is implemented with a simple [AnimatedBuilder] +
/// [LinearGradient] animation — no external dependency needed.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.child,
  });

  /// The skeleton layout (grey boxes) to animate.
  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);
    final highlightColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFF2F2F7);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // Slide the highlight gradient across the bounds.
            final t = _controller.value;
            final width = bounds.width;
            final highlightWidth = width * 0.3;
            final dx = (t * (width + highlightWidth)) - highlightWidth;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              stops: [
                0,
                dx / width,
                (dx + highlightWidth) / width,
                (dx + highlightWidth * 2) / width,
                1,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A skeleton placeholder shaped like an exercise card in grid layout.
class ExerciseCardSkeleton extends StatelessWidget {
  const ExerciseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(height: 140, radius: AppRadius.xl),
          SizedBox(height: AppSpacing.sm),
          _SkeletonBox(height: 14),
          SizedBox(height: AppSpacing.xs),
          _SkeletonBox(height: 12, width: 100),
        ],
      ),
    );
  }
}

/// A skeleton placeholder shaped like an exercise list row.
class ExerciseListRowSkeleton extends StatelessWidget {
  const ExerciseListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Row(
        children: [
          _SkeletonBox(width: 64, height: 64, radius: AppRadius.md),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 14),
                SizedBox(height: AppSpacing.xs),
                _SkeletonBox(height: 12, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single grey rounded rectangle used inside skeletons.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    this.height = 16,
    this.radius = AppRadius.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // ShaderMask replaces this with the gradient.
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
