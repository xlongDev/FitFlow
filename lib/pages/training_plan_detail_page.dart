import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/training_plan_model.dart';
import '../../providers/database_providers.dart';
import '../../providers/training_plan_provider.dart';
import '../../routers/route_names.dart';
import '../../theme/theme.dart';
import '../../widgets/common/states.dart';
import '../../widgets/glass/glass.dart';

/// The training plan detail page.
///
/// Shows a single plan with all its days and exercises. Supports:
///   * Adding / removing days.
///   * Adding / removing exercises to a day.
///   * Editing exercise config (sets, reps, weight, rest, notes).
///   * Reordering days and exercises.
class TrainingPlanDetailPage extends ConsumerWidget {
  const TrainingPlanDetailPage({
    super.key,
    required this.planId,
  });

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlan = ref.watch(trainingPlanDetailProvider(planId));

    return Scaffold(
      appBar: AppBar(
        title: asyncPlan.maybeWhen(
          data: (plan) => Text(plan?.name ?? 'Plan'),
          orElse: () => const Text('Loading...'),
        ),
        actions: [
          asyncPlan.maybeWhen(
            data: (plan) => plan != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit plan',
                    onPressed: () => _showEditPlanDialog(context, ref, plan),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncPlan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(trainingPlanDetailProvider(planId)),
        ),
        data: (plan) {
          if (plan == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Plan not found',
              subtitle: 'This plan may have been deleted.',
            );
          }
          return _PlanContent(plan: plan);
        },
      ),
    );
  }

  Future<void> _showEditPlanDialog(
    BuildContext context,
    WidgetRef ref,
    TrainingPlanModel plan,
  ) async {
    final nameController = TextEditingController(text: plan.name);
    final descController = TextEditingController(text: plan.description);

    final result = await GlassDialog.show<bool>(
      context,
      options: const GlassDialogOptions(title: 'Edit Plan'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: descController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Save',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result == true && context.mounted) {
      final repo = ref.read(trainingPlanRepositoryProvider);
      await repo.updatePlan(
        plan.copyWith(
          name: nameController.text.trim(),
          description: descController.text.trim(),
        ),
      );
      ref.invalidate(trainingPlanDetailProvider(planId));
    }
  }
}

/// The plan content — list of days.
class _PlanContent extends ConsumerWidget {
  const _PlanContent({required this.plan});

  final TrainingPlanModel plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (plan.days.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No training days',
        subtitle: 'Add a day to start building your plan.',
        actionLabel: 'Add Day',
        onAction: () => _addDay(context, ref),
      );
    }

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: plan.days.length + 1, // +1 for the add-day button
      itemBuilder: (context, index) {
        if (index == plan.days.length) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: GlassButton(
              label: 'Add Day',
              icon: Icons.add,
              style: GlassButtonStyle.secondary,
              onPressed: () => _addDay(context, ref),
              expanded: true,
            ),
          );
        }
        final day = plan.days[index];
        return _DaySection(plan: plan, day: day);
      },
    );
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final result = await GlassDialog.show<bool>(
      context,
      options: const GlassDialogOptions(title: 'Add Training Day'),
      child: TextField(
        controller: nameController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Day name (e.g. Push, Pull, Legs)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Add',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final repo = ref.read(trainingPlanRepositoryProvider);
      await repo.addDay(
        plan.id,
        nameController.text.trim(),
        plan.days.length,
      );
      ref.invalidate(trainingPlanDetailProvider(plan.id));
    }
  }
}

/// A single day section with its exercises.
class _DaySection extends ConsumerWidget {
  const _DaySection({required this.plan, required this.day});

  final TrainingPlanModel plan;
  final TrainingDayModel day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Expanded(
                child: Text(
                  day.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Delete day',
                onPressed: () => _deleteDay(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Exercises
          if (day.exercises.isEmpty)
            Text(
              'No exercises yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          else
            ...day.exercises.map((ex) => _ExerciseTile(
                  plan: plan,
                  day: day,
                  exercise: ex,
                )),
          const SizedBox(height: AppSpacing.sm),
          // Add exercise button
          GlassButton(
            label: 'Add Exercise',
            icon: Icons.add,
            style: GlassButtonStyle.text,
            onPressed: () => _addExercise(context, ref),
            expanded: true,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDay(BuildContext context, WidgetRef ref) async {
    final confirmed = await GlassDialog.show<bool>(
      context,
      options: GlassDialogOptions(title: 'Delete "${day.name}"?'),
      child: const Text('This will remove the day and all its exercises.'),
      actions: [
        GlassButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.text,
        ),
        GlassButton(
          label: 'Delete',
          onPressed: () => Navigator.of(context).pop(true),
          style: GlassButtonStyle.destructive,
        ),
      ],
    );

    if (confirmed == true) {
      final repo = ref.read(trainingPlanRepositoryProvider);
      await repo.deleteDay(day.id);
      ref.invalidate(trainingPlanDetailProvider(plan.id));
    }
  }

  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    // For now, navigate to the exercise library to pick an exercise.
    // A proper exercise picker will be built in a later iteration.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Browse exercises and tap "Add to plan" to add here.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (context.mounted) {
      await context.push(RouteNames.exerciseLibraryPath);
    }
  }
}

/// A single exercise tile within a day.
class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({
    required this.plan,
    required this.day,
    required this.exercise,
  });

  final TrainingPlanModel plan;
  final TrainingDayModel day;
  final TrainingExerciseModel exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GlassCard(
        onTap: () => _editExercise(context, ref),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs3),
                  Text(
                    '${exercise.sets} sets × ${exercise.reps} reps'
                    '${exercise.weight > 0 ? ' @ ${exercise.weight}kg' : ''}'
                    ' · ${exercise.restSeconds}s rest',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _editExercise(BuildContext context, WidgetRef ref) async {
    final setsController =
        TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps);
    final weightController =
        TextEditingController(text: exercise.weight.toString());
    final restController =
        TextEditingController(text: exercise.restSeconds.toString());
    final notesController = TextEditingController(text: exercise.notes);

    final result = await GlassDialog.show<bool>(
      context,
      options: GlassDialogOptions(title: exercise.exerciseName),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NumberField(
              controller: setsController,
              label: 'Sets',
              icon: Icons.repeat,
            ),
            const SizedBox(height: AppSpacing.sm),
            _NumberField(
              controller: repsController,
              label: 'Reps (e.g. 8 or 8-12)',
              icon: Icons.fitness_center,
              isText: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            _NumberField(
              controller: weightController,
              label: 'Weight (kg)',
              icon: Icons.scale,
            ),
            const SizedBox(height: AppSpacing.sm),
            _NumberField(
              controller: restController,
              label: 'Rest (seconds)',
              icon: Icons.timer,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          label: 'Delete',
          onPressed: () => Navigator.of(context).pop(false),
          style: GlassButtonStyle.destructive,
        ),
        GlassButton(
          label: 'Save',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result == null) return;

    final repo = ref.read(trainingPlanRepositoryProvider);
    if (result == false) {
      // Delete
      await repo.removeExercise(exercise.id);
    } else {
      // Save
      await repo.updateExercise(
        exercise.copyWith(
          sets: int.tryParse(setsController.text) ?? exercise.sets,
          reps: repsController.text.trim(),
          weight: double.tryParse(weightController.text) ?? exercise.weight,
          restSeconds: int.tryParse(restController.text) ?? exercise.restSeconds,
          notes: notesController.text.trim(),
        ),
      );
    }
    ref.invalidate(trainingPlanDetailProvider(plan.id));
  }
}

/// A number input field with an icon and label.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
