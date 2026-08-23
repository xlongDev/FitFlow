import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/exercise_model.dart';
import '../../providers/exercise_detail_provider.dart';
import '../../theme/theme.dart';
import '../../utils/app_logger.dart';
import '../../widgets/common/states.dart';
import '../../widgets/exercise/exercise_gif_viewer.dart';
import '../../widgets/exercise/exercise_instructions.dart';
import '../../widgets/exercise/exercise_metadata_card.dart';
import '../../widgets/exercise/favorite_button.dart';
import '../../widgets/glass/glass.dart';

/// The exercise detail page.
///
/// Shows a single exercise with:
///   * A full-bleed GIF header with parallax scroll.
///   * Hero animation from the library card.
///   * Metadata card (body part, equipment, target, muscles).
///   * Multilingual instructions + step-by-step tutorial.
///   * Favorite + add-to-plan actions (Phase 5 / Phase 6 will wire these).
///   * Copyright footer.
class ExerciseDetailPage extends ConsumerWidget {
  const ExerciseDetailPage({
    super.key,
    required this.exerciseId,
  });

  /// The exercise id to display.
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExercise = ref.watch(exerciseDetailProvider(exerciseId));

    return Scaffold(
      body: asyncExercise.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(exerciseDetailProvider(exerciseId)),
        ),
        data: (exercise) {
          if (exercise == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Exercise not found',
              subtitle: 'This exercise may have been removed.',
            );
          }
          return _ExerciseDetailContent(exercise: exercise);
        },
      ),
    );
  }
}

/// Skeleton placeholder shown while the exercise loads.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// The main content of the detail page, shown once the exercise loads.
class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // GIF header with parallax + back/favorite buttons
        SliverAppBar(
          expandedHeight: 320,
          stretch: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              // Parallax: translate the GIF up as the user scrolls down.
              final scrollProgress = (320 - constraints.biggest.height) / 320;
              final parallax = (scrollProgress * 80).clamp(0.0, 80.0);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(0, -parallax),
                    child: ExerciseGifViewer(
                      gifPath: exercise.gifUrl,
                      aspectRatio: 0.75,
                    ),
                  ),
                  // Gradient overlay for button legibility
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Theme.of(context)
                                .scaffoldBackgroundColor
                                .withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Top action bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            _BackButton(),
                            const Spacer(),
                            FavoriteButton(
                              exerciseId: exercise.id,
                              onColor: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Body content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + body part
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  exercise.bodyPart,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Metadata card
                ExerciseMetadataCard(exercise: exercise),
                const SizedBox(height: AppSpacing.xl),

                // Instructions + steps
                ExerciseInstructions(exercise: exercise),
                const SizedBox(height: AppSpacing.xl),

                // Add to plan button (Phase 6 will wire this)
                GlassButton(
                  label: 'Add to Training Plan',
                  icon: Icons.add,
                  onPressed: () {
                    AppLogger.d('Add to plan tapped for ${exercise.id} (Phase 6)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Training plans coming in Phase 6'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  expanded: true,
                ),
                const SizedBox(height: AppSpacing.xl2),

                // Copyright footer
                const Center(
                  child: Text('© Gym visual — gymvisual.com'),
                ),
                const SizedBox(height: AppSpacing.xl2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A frosted-glass back button.
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
