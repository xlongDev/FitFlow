import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/watch_message_model.dart';
import '../../providers/watch_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The Apple Watch status page — shows connection state and a communication
/// demo.
///
/// Displays whether the watch is paired / reachable, the current workout
/// snapshot (heart rate, calories, progress), and buttons to test the
/// communication (start/stop workout, ping).
class WatchStatusPage extends ConsumerWidget {
  const WatchStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.watchTitle)),
      body: switch (state) {
        WatchInitial() || WatchChecking() =>
          const Center(child: CircularProgressIndicator()),
        WatchDisconnected(:final isAvailable) => _DisconnectedState(
            isAvailable: isAvailable,
            onRetry: () => ref.read(watchProvider.notifier).refresh(),
          ),
        WatchConnected(:final snapshot) => _ConnectedState(
            snapshot: snapshot,
            onStartWorkout: () =>
                ref.read(watchProvider.notifier).startWorkout(totalSets: 10),
            onStopWorkout: () =>
                ref.read(watchProvider.notifier).stopWorkout(),
            onPing: () => ref.read(watchProvider.notifier).ping(),
          ),
        WatchError(:final message) => ErrorState(
            message: message,
            onRetry: () => ref.read(watchProvider.notifier).refresh(),
          ),
      },
    );
  }
}

class _DisconnectedState extends StatelessWidget {
  const _DisconnectedState({required this.isAvailable, required this.onRetry});

  final bool isAvailable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.watch_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l.watchNotConnected, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAvailable ? l.watchNotPaired : l.watchNotAvailable,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassButton(
              label: l.retry,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedState extends StatelessWidget {
  const _ConnectedState({
    required this.snapshot,
    required this.onStartWorkout,
    required this.onStopWorkout,
    required this.onPing,
  });

  final WatchWorkoutSnapshot snapshot;
  final VoidCallback onStartWorkout;
  final VoidCallback onStopWorkout;
  final VoidCallback onPing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // Connection status
        GlassContainer(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.watchConnected, style: theme.textTheme.titleMedium),
                    Text(l.watchReachable, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.watch, size: 32, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Workout snapshot
        Text(l.watchWorkoutSnapshot, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                icon: Icons.favorite,
                label: l.watchHeartRate,
                value: '${snapshot.heartRate}',
                unit: 'bpm',
                color: AppColors.error,
              ),
              _MetricCard(
                icon: Icons.local_fire_department,
                label: l.watchCalories,
                value: snapshot.calories.toStringAsFixed(0),
                unit: 'kcal',
                color: AppColors.secondary,
              ),
              _MetricCard(
                icon: Icons.fitness_center,
                label: l.watchProgress,
                value: '${snapshot.completedSets}/${snapshot.totalSets}',
                unit: l.watchSets,
                color: AppColors.primary,
              ),
              _MetricCard(
                icon: Icons.timer,
                label: l.watchElapsed,
                value: '${snapshot.elapsedSeconds ~/ 60}:${(snapshot.elapsedSeconds % 60).toString().padLeft(2, '0')}',
                unit: '',
                color: AppColors.tertiary,
              ),
            ],
          ),
          if (snapshot.currentExercise.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            GlassContainer(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  const Icon(Icons.play_arrow, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      snapshot.currentExercise,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),

        // Action buttons
        GlassButton(
          label: l.watchStartWorkout,
          icon: Icons.play_arrow,
          expanded: true,
          onPressed: onStartWorkout,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassButton(
          label: l.watchStopWorkout,
          icon: Icons.stop,
          style: GlassButtonStyle.secondary,
          expanded: true,
          onPressed: onStopWorkout,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassButton(
          label: l.watchPing,
          icon: Icons.wifi_protected_setup,
          style: GlassButtonStyle.text,
          expanded: true,
          onPressed: onPing,
        ),
        const SizedBox(height: AppSpacing.xl2),
        Center(
          child: Text(
            l.watchDemoNote,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
