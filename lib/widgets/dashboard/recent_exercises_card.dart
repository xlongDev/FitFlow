import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/exercise_model.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Recent exercises card — horizontal scroll of recently viewed exercises.
class RecentExercisesCard extends ConsumerWidget {
  const RecentExercisesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final l = AppLocalizations.of(context)!;

    if (state is! HomeDashboardDataState) {
      return const SizedBox.shrink();
    }

    final exercises = state.data.recentExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: Text(l.navRecent, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
            itemCount: exercises.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _ExerciseChip(exercise: exercise);
            },
          ),
        ),
      ],
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.exerciseLibraryPath}/${exercise.id}'),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          width: 80,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.outline),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
