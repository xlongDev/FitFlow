import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/home_dashboard_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../glass/glass.dart';

/// Today's workout card — shows the scheduled workout for today or a
/// "no workout" prompt with a link to the calendar.
class TodayWorkoutCard extends ConsumerWidget {
  const TodayWorkoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final l = AppLocalizations.of(context)!;

    if (state is! HomeDashboardDataState) {
      return const SizedBox.shrink();
    }

    final workout = state.data.todayWorkout;

    if (workout == null) {
      return GlassCard(
        onTap: () => context.push(RouteNames.trainingCalendarPath),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.dashboardNoWorkoutToday, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(l.dashboardScheduleWorkout, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiaryLight),
          ],
        ),
      );
    }

    if (workout.isRestDay) {
      return GlassContainer(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.dashboardRestDay, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(l.dashboardEnjoyRest, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      onTap: () => context.push(RouteNames.workoutSessionPath, extra: {
        'scheduledWorkoutId': workout.id.toString(),
        'planId': workout.planId,
        'planName': workout.planName,
        'dayName': workout.dayName,
      }),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: workout.isCompleted ? AppColors.tertiary : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              workout.isCompleted ? Icons.check : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.dayName ?? l.dashboardTodayWorkout,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs3),
                Text(
                  workout.planName ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          if (!workout.isCompleted)
            const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
        ],
      ),
    );
  }
}
