
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/default_diet_plans_service.dart';
import '../services/default_plans_service.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// Result of a default-plans import.
class DefaultPlansImportResult {
  const DefaultPlansImportResult({
    required this.trainingPlansCreated,
    required this.dietPlansCreated,
  });

  final int trainingPlansCreated;
  final int dietPlansCreated;

  @override
  String toString() =>
      'DefaultPlansImportResult(trainingPlans: $trainingPlansCreated, '
      'dietPlans: $dietPlansCreated)';
}

/// Provider that imports default plans on first launch.
///
/// Checks whether any training plans exist. If not, creates all default
/// training plans + diet plans from the template services. Returns the
/// count of created plans so the UI can show a summary.
///
/// This provider is called from [SplashPage] on every launch — it's a
/// no-op if plans already exist (idempotent).
final defaultPlansImportProvider =
    FutureProvider<DefaultPlansImportResult?>((ref) async {
  final trainingPlanRepo = ref.watch(trainingPlanRepositoryProvider);
  final dietRepo = ref.watch(dietRepositoryProvider);

  // Check if any training plans already exist.
  final existingPlans = await trainingPlanRepo.allPlans();
  if (existingPlans.isNotEmpty) {
    AppLogger.d('DefaultPlans: ${existingPlans.length} plans already exist, skipping import');
    return null;
  }

  AppLogger.i('DefaultPlans: first launch, importing default plans');

  // --- Import training plans ---
  var trainingCount = 0;
  for (final template in DefaultPlansService.all) {
    final planId = await trainingPlanRepo.createPlan(
      name: template.name,
      description: template.description,
      goal: template.goal,
      daysPerWeek: template.daysPerWeek,
    );

    for (var i = 0; i < template.days.length; i++) {
      final day = template.days[i];
      final dayId = await trainingPlanRepo.addDay(planId, day.name, i);

      for (var j = 0; j < day.exercises.length; j++) {
        final ex = day.exercises[j];
        await trainingPlanRepo.addExercise(
          dayId: dayId,
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          sets: ex.sets,
          reps: ex.reps,
          weight: ex.weight,
          restSeconds: ex.restSeconds,
          notes: ex.notes,
        );
      }
    }
    trainingCount++;
  }

  // --- Import diet plans ---
  var dietCount = 0;
  for (final template in DefaultDietPlansService.all) {
    await dietRepo.createPlan(
      name: template.name,
      goal: template.goal,
      targetCalories: template.targetCalories,
      targetProtein: template.targetProtein,
      targetCarbs: template.targetCarbs,
      targetFat: template.targetFat,
    );
    dietCount++;
  }

  // Activate the first diet plan as default.
  final allDietPlans = await dietRepo.allPlans();
  if (allDietPlans.isNotEmpty) {
    await dietRepo.setActivePlan(allDietPlans.first.id);
  }

  AppLogger.i('DefaultPlans: imported $trainingCount training plans, '
      '$dietCount diet plans');

  return DefaultPlansImportResult(
    trainingPlansCreated: trainingCount,
    dietPlansCreated: dietCount,
  );
});
