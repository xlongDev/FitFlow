import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_plan_model.dart';
import '../repositories/training_plan_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// State for the training plan list page.
sealed class TrainingPlanListState {
  const TrainingPlanListState();
}

class TrainingPlanListLoading extends TrainingPlanListState {
  const TrainingPlanListLoading();
}

class TrainingPlanListData extends TrainingPlanListState {
  const TrainingPlanListData(this.plans);

  final List<TrainingPlanModel> plans;
}

class TrainingPlanListError extends TrainingPlanListState {
  const TrainingPlanListError(this.message);

  final String message;
}

/// Notifier that manages the training plan list.
class TrainingPlanListNotifier
    extends Notifier<TrainingPlanListState> {
  late TrainingPlanRepository _repo;

  @override
  TrainingPlanListState build() {
    _repo = ref.watch(trainingPlanRepositoryProvider);
    unawaited(_load());
    return const TrainingPlanListLoading();
  }

  Future<void> _load() async {
    try {
      final plans = await _repo.allPlans();
      if (!ref.mounted) return;
      state = TrainingPlanListData(plans);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Failed to load training plans', e, st);
      state = TrainingPlanListError(e.toString());
    }
  }

  /// Reloads the list from the database.
  Future<void> refresh() => _load();

  /// Creates a new plan and refreshes the list.
  ///
  /// Returns the new plan's id.
  Future<String> createPlan({
    required String name,
    String description = '',
    String goal = '',
    int daysPerWeek = 3,
  }) async {
    final id = await _repo.createPlan(
      name: name,
      description: description,
      goal: goal,
      daysPerWeek: daysPerWeek,
    );
    await _load();
    return id;
  }

  /// Deletes a plan and refreshes the list.
  Future<void> deletePlan(String planId) async {
    await _repo.deletePlan(planId);
    await _load();
  }

  /// Duplicates a plan and refreshes the list.
  ///
  /// Returns the new plan's id.
  Future<String> duplicatePlan(String planId) async {
    final newId = await _repo.duplicatePlan(planId);
    await _load();
    return newId;
  }
}

/// Provider that exposes the [TrainingPlanListNotifier].
final trainingPlanListProvider =
    NotifierProvider<TrainingPlanListNotifier, TrainingPlanListState>(
  TrainingPlanListNotifier.new,
);

/// Family provider that loads a single plan with all its days and exercises.
final trainingPlanDetailProvider =
    FutureProvider.family<TrainingPlanModel?, String>((ref, planId) async {
  final repo = ref.watch(trainingPlanRepositoryProvider);
  return repo.getPlan(planId);
});
