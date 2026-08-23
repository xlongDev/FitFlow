import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/exercise_model.dart';
import '../../theme/theme.dart';
import '../../utils/media_url_resolver.dart';
import '../common/skeleton_shimmer.dart';
import '../glass/glass.dart';

/// A single exercise displayed as a tappable card.
///
/// Renders in two layouts depending on [layout]:
///   * [ExerciseCardLayout.grid] — vertical card with a large GIF thumbnail
///     on top and the name + body part below. Used in the 2-column grid.
///   * [ExerciseCardLayout.list] — horizontal row with a small square
///     thumbnail on the left and the name + metadata on the right.
///
/// Both layouts use [GlassCard] as the container and [CachedNetworkImage]
/// for the GIF so images are cached after first load.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.layout = ExerciseCardLayout.grid,
  });

  /// The exercise to display.
  final ExerciseModel exercise;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// The visual layout.
  final ExerciseCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      ExerciseCardLayout.grid => _GridCard(exercise: exercise, onTap: onTap),
      ExerciseCardLayout.list => _ListRow(exercise: exercise, onTap: onTap),
    };
  }
}

/// Layout variants for [ExerciseCard].
enum ExerciseCardLayout { grid, list }

// ---------------------------------------------------------------------------
// Grid layout
// ---------------------------------------------------------------------------

class _GridCard extends StatelessWidget {
  const _GridCard({required this.exercise, required this.onTap});

  final ExerciseModel exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GIF thumbnail — fills the card width, fixed aspect ratio.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _ExerciseGif(
                url: MediaUrlResolver.resolve(exercise.gifUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs3),
                _BodyPartChip(bodyPart: exercise.bodyPart),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List layout
// ---------------------------------------------------------------------------

class _ListRow extends StatelessWidget {
  const _ListRow({required this.exercise, required this.onTap});

  final ExerciseModel exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _ExerciseGif(
                url: MediaUrlResolver.resolve(exercise.gifUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs3),
                Row(
                  children: [
                    _BodyPartChip(bodyPart: exercise.bodyPart),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        exercise.equipment,
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

/// A small chip showing the body-part name (e.g. "chest").
class _BodyPartChip extends StatelessWidget {
  const _BodyPartChip({required this.bodyPart});

  final String bodyPart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        bodyPart,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// A cached network GIF with a shimmer placeholder and error fallback.
///
/// Centralizes the loading / error states so every exercise thumbnail
/// behaves the same way. The placeholder uses [SkeletonShimmer] for a
/// consistent loading experience.
class _ExerciseGif extends StatelessWidget {
  const _ExerciseGif({required this.url, required this.fit});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, _) => const SkeletonShimmer(
        child: _FillSkeleton(),
      ),
      errorWidget: (_, _, _) => _ErrorPlaceholder(),
    );
  }
}

/// A skeleton that fills its parent (used as the GIF loading placeholder).
class _FillSkeleton extends StatelessWidget {
  const _FillSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    );
  }
}

/// A fallback icon shown when the GIF fails to load.
class _ErrorPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.outline,
        size: 32,
      ),
    );
  }
}
