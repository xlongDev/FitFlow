import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/media_url_resolver.dart';
import '../common/skeleton_shimmer.dart';

/// A full-bleed exercise GIF viewer with loading / error states.
///
/// Used at the top of the exercise detail page. The GIF fills the available
/// width and uses a 16:9-ish aspect ratio so it doesn't dominate the screen.
/// While loading, a shimmer placeholder is shown; on error, a broken-image
/// icon.
class ExerciseGifViewer extends StatelessWidget {
  const ExerciseGifViewer({
    super.key,
    required this.gifPath,
    this.aspectRatio = 1.2,
  });

  /// Relative path from the exercise dataset (e.g. `videos/0001-2gPfomN.gif`).
  final String gifPath;

  /// Aspect ratio of the viewer. Defaults to 1.2 (slightly wider than tall)
  /// which suits the 180x180 source GIFs when scaled up.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final url = MediaUrlResolver.resolve(gifPath);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => const SkeletonShimmer(
            child: _FillSkeleton(),
          ),
          errorWidget: (_, _, _) => const _GifErrorPlaceholder(),
        ),
      ),
    );
  }
}

class _FillSkeleton extends StatelessWidget {
  const _FillSkeleton();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const SizedBox.expand(),
    );
  }
}

class _GifErrorPlaceholder extends StatelessWidget {
  const _GifErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'GIF unavailable',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
