import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/exercise_model.dart';
import '../../models/workout_session_model.dart';
import '../../providers/exercise_detail_provider.dart';
import '../../providers/workout_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';
import '../../widgets/workout/rest_timer_widget.dart';

/// The workout session page — the live workout experience.
///
/// Shows the active session's elapsed time, total volume, and set list.
/// The user can:
///   * Add exercises from the library.
///   * Log sets (weight + reps) for each exercise.
///   * Mark sets complete (which triggers the rest timer).
///   * Finish the workout (which finalizes the session and marks the
///     calendar entry complete).
class WorkoutSessionPage extends ConsumerStatefulWidget {
  const WorkoutSessionPage({
    super.key,
    this.scheduledWorkoutId,
    this.planDayId,
    this.planId,
    this.planName,
    this.dayName,
  });

  final String? scheduledWorkoutId;
  final String? planDayId;
  final String? planId;
  final String? planName;
  final String? dayName;

  @override
  ConsumerState<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends ConsumerState<WorkoutSessionPage> {
  bool _restTimerVisible = false;
  int _restDuration = 90;

  @override
  void initState() {
    super.initState();
    // Start the session on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(workoutSessionProvider);
      if (state is WorkoutIdle) {
        unawaited(ref.read(workoutSessionProvider.notifier).startSession(
          scheduledWorkoutId: widget.scheduledWorkoutId,
          planDayId: widget.planDayId,
          planId: widget.planId,
          planName: widget.planName,
          dayName: widget.dayName,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayName ?? 'Workout'),
        actions: [
          if (state is WorkoutActive)
            TextButton(
              onPressed: () => _confirmFinish(context),
              child: const Text('Finish'),
            ),
        ],
      ),
      body: state is WorkoutActive
          ? _SessionBody(
              state: state,
              onAddExercise: () => _navigateToExercisePicker(context),
              onSetCompleted: _onSetCompleted,
              onRemoveSet: _onRemoveSet,
              restTimerVisible: _restTimerVisible,
              restDuration: _restDuration,
              onRestComplete: () => setState(() => _restTimerVisible = false),
              onRestDismiss: () => setState(() => _restTimerVisible = false),
            )
          : state is WorkoutIdle
              ? const Center(child: CircularProgressIndicator())
              : ErrorState(
                  message: 'Unknown session state',
                  onRetry: () => ref.invalidate(workoutSessionProvider),
                ),
    );
  }

  void _onSetCompleted(SetRecordModel set) {
    unawaited(ref.read(workoutSessionProvider.notifier).toggleSetCompletion(set.id));
    // Show rest timer when a set is completed.
    setState(() {
      _restTimerVisible = true;
      _restDuration = 90;
    });
  }

  void _onRemoveSet(String setId) {
    unawaited(ref.read(workoutSessionProvider.notifier).removeSet(setId));
  }

  Future<void> _navigateToExercisePicker(BuildContext context) async {
    // Navigate to the exercise library for the user to pick an exercise.
    // The selected exercise id is returned via the route's return value.
    final result = await context.push<String>(RouteNames.exerciseLibraryPath);
    if (result != null && mounted) {
      // Load the exercise to get its name.
      final exercise = await _loadExercise(result);
      if (exercise != null && mounted) {
        // Calculate the next set number for this exercise.
        final s = ref.read(workoutSessionProvider);
        final existingSets = s is WorkoutActive
            ? s.sets.where((set) => set.exerciseId == exercise.id).length
            : 0;
        await ref.read(workoutSessionProvider.notifier).addSet(
              exerciseId: exercise.id,
              exerciseName: exercise.name,
              setNumber: existingSets + 1,
              weight: 0,
              reps: 0,
            );
      }
    }
  }

  /// Loads an exercise by id, polling until the FutureProvider resolves.
  Future<ExerciseModel?> _loadExercise(String id) async {
    for (var i = 0; i < 20; i++) {
      final asyncValue = ref.read(exerciseDetailProvider(id));
      final exercise = asyncValue.value;
      if (exercise != null) return exercise;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return null;
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final confirmed = await GlassDialog.show<bool>(
      context,
      options: const GlassDialogOptions(title: 'Finish Workout?'),
      child: const Text(
        'This will finalize your workout session and mark it complete.',
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Finish',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed == true && mounted) {
      await ref.read(workoutSessionProvider.notifier).finishSession();
      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout completed!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RouteNames.trainingCalendarPath);
    }
  }
}

/// The session body — header stats + set list + rest timer overlay.
class _SessionBody extends ConsumerWidget {
  const _SessionBody({
    required this.state,
    required this.onAddExercise,
    required this.onSetCompleted,
    required this.onRemoveSet,
    required this.restTimerVisible,
    required this.restDuration,
    required this.onRestComplete,
    required this.onRestDismiss,
  });

  final WorkoutActive state;
  final VoidCallback onAddExercise;
  final void Function(SetRecordModel) onSetCompleted;
  final void Function(String) onRemoveSet;
  final bool restTimerVisible;
  final int restDuration;
  final VoidCallback onRestComplete;
  final VoidCallback onRestDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutSessionProvider);
    if (state is! WorkoutActive) {
      return const Center(child: CircularProgressIndicator());
    }
    final minutes = (state.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header stats
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        label: 'Time',
                        value: '$minutes:$seconds',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.fitness_center,
                        label: 'Volume',
                        value: '${state.totalVolume.toStringAsFixed(0)} kg',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Sets',
                        value: '${state.completedSets}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Set list grouped by exercise
            if (state.sets.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.add_circle_outline,
                  title: 'No exercises yet',
                  subtitle: 'Tap the + button to add exercises to your workout.',
                  actionLabel: 'Add Exercise',
                  onAction: onAddExercise,
                ),
              )
            else
              SliverList.builder(
                itemCount: state.sets.length,
                itemBuilder: (context, index) {
                  final set = state.sets[index];
                  return _SetTile(
                    set: set,
                    onToggleComplete: () => onSetCompleted(set),
                    onRemove: () => onRemoveSet(set.id),
                  );
                },
              ),

            // Add exercise button
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: GlassButton(
                  label: 'Add Exercise',
                  icon: Icons.add,
                  style: GlassButtonStyle.secondary,
                  onPressed: onAddExercise,
                  expanded: true,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl2)),
          ],
        ),

        // Rest timer overlay
        if (restTimerVisible)
          Positioned(
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            bottom: AppSpacing.xl2,
            child: RestTimerWidget(
              durationSeconds: restDuration,
              onComplete: onRestComplete,
              onDismiss: onRestDismiss,
            ),
          ),
      ],
    );
  }
}

/// A compact stat card showing an icon, label, and value.
class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs3),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.5,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single set tile showing exercise name, set number, weight, reps, and
/// completion toggle.
class _SetTile extends StatelessWidget {
  const _SetTile({
    required this.set,
    required this.onToggleComplete,
    required this.onRemove,
  });

  final SetRecordModel set;
  final VoidCallback onToggleComplete;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: GlassCard(
        onTap: onToggleComplete,
        child: Row(
          children: [
            // Completion checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? AppColors.tertiary
                    : Colors.transparent,
                border: Border.all(
                  color: set.isCompleted
                      ? AppColors.tertiary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: set.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            // Exercise name + set number
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.exerciseName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          set.isCompleted ? TextDecoration.lineThrough : null,
                      color: set.isCompleted
                          ? theme.colorScheme.outline
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(
                    'Set ${set.setNumber} · ${set.weight.toStringAsFixed(1)} kg × ${set.reps} reps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              tooltip: 'Remove set',
            ),
          ],
        ),
      ),
    );
  }
}
