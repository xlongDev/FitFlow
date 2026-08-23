import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/diet_model.dart';
import '../repositories/diet_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// State for the diet page — the selected date's records + nutrition summary
/// + the active plan's targets.
class DietState {
  const DietState({
    required this.selectedDate,
    required this.summary,
    required this.activePlan,
  });

  final DateTime selectedDate;
  final NutritionSummary summary;
  final DietPlanModel? activePlan;

  DietState copyWith({
    DateTime? selectedDate,
    NutritionSummary? summary,
    DietPlanModel? activePlan,
  }) {
    return DietState(
      selectedDate: selectedDate ?? this.selectedDate,
      summary: summary ?? this.summary,
      activePlan: activePlan ?? this.activePlan,
    );
  }
}

/// Notifier that manages the diet page state.
///
/// Loads the selected date's records + summary + the active plan. When the
/// user adds / removes a record or changes the date, the state is refreshed.
class DietNotifier extends Notifier<DietState> {
  late DietRepository _repo;

  @override
  DietState build() {
    _repo = ref.watch(dietRepositoryProvider);

    final today = _normalizeDate(DateTime.now());
    final initial = DietState(
      selectedDate: today,
      summary: const NutritionSummary(
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        records: [],
      ),
      activePlan: null,
    );

    unawaited(_load(initial));
    return initial;
  }

  Future<void> _load(DietState s) async {
    try {
      final summary = await _repo.getSummaryForDate(s.selectedDate);
      final plan = await _repo.activePlan();
      if (!ref.mounted) return;
      state = s.copyWith(summary: summary, activePlan: plan);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Diet: failed to load', e, st);
    }
  }

  /// Changes the selected date and reloads.
  Future<void> selectDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    state = state.copyWith(selectedDate: normalized);
    await _load(state);
  }

  /// Adds a food record and refreshes the summary.
  Future<void> addRecord(DietRecordModel record) async {
    await _repo.addRecord(record);
    await _load(state);
  }

  /// Removes a record and refreshes the summary.
  Future<void> removeRecord(String id) async {
    await _repo.removeRecord(id);
    await _load(state);
  }

  /// Refreshes the state (e.g. after activating a new plan).
  Future<void> refresh() async => _load(state);

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// Provider that exposes the [DietNotifier].
final dietProvider = NotifierProvider<DietNotifier, DietState>(
  DietNotifier.new,
);

/// Provider that loads all diet plans for the plan list page.
final dietPlanListProvider = FutureProvider<List<DietPlanModel>>((ref) async {
  final repo = ref.watch(dietRepositoryProvider);
  return repo.allPlans();
});
