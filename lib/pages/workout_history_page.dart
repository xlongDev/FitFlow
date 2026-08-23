import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout_session_model.dart';
import '../../providers/workout_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/skeleton_shimmer.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The workout history page.
///
/// Shows all completed workout sessions, newest first. Each entry shows the
/// date, duration, total volume, and number of sets completed.
class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: asyncHistory.when(
        loading: () => const _LoadingList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(workoutHistoryProvider),
        ),
        data: (sessions) => sessions.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                title: 'No workouts yet',
                subtitle: 'Complete a workout to see it here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  bottom: AppSpacing.xl2,
                ),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _HistoryCard(session: session),
                  );
                },
              ),
      ),
    );
  }
}

/// A single history entry card.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session});

  final WorkoutSessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startedAt = DateTime.tryParse(session.startedAt);
    final dateText = startedAt != null
        ? '${startedAt.year}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}'
        : 'Unknown date';
    final timeText = startedAt != null
        ? '${startedAt.hour.toString().padLeft(2, '0')}:${startedAt.minute.toString().padLeft(2, '0')}'
        : '';

    final durationText = session.durationSeconds != null
        ? '${session.durationSeconds! ~/ 60}m ${session.durationSeconds! % 60}s'
        : 'In progress';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + time header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timeText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          if (session.planName != null || session.dayName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              [session.planName, session.dayName]
                  .whereType<String>()
                  .join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: durationText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatChip(
                  icon: Icons.fitness_center,
                  label: 'Volume',
                  value: '${session.totalVolume.toStringAsFixed(0)} kg',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatChip(
                  icon: Icons.check_circle,
                  label: 'Sets',
                  value: '${session.setsCompleted}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact stat chip with icon, label, and value.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.xs3),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs3),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 0.3,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      itemCount: 5,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: ExerciseListRowSkeleton(),
      ),
    );
  }
}
