import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_metric_model.dart';
import '../models/diet_model.dart';
import '../models/exercise_model.dart';
import '../models/training_plan_model.dart';
import '../models/workout_session_model.dart';
import '../repositories/calendar_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// Aggregated dashboard data for the home page.
///
/// Pulls data from multiple providers / repositories in parallel so the
/// home page can render everything in one pass. Each field is nullable —
/// if a module has no data, the corresponding card is hidden.
class HomeDashboardData {
  const HomeDashboardData({
    this.todayWorkout,
    this.activePlan,
    this.recentExercises = const [],
    this.favoriteExercises = const [],
    this.latestBodyMetric,
    this.todayNutrition,
    this.recentWorkouts = const [],
  });

  /// Today's scheduled workout (null if none scheduled).
  final ScheduledWorkoutModel? todayWorkout;

  /// The user's first training plan (null if none).
  final TrainingPlanModel? activePlan;

  /// Recently viewed exercises (empty if none).
  final List<ExerciseModel> recentExercises;

  /// Favorite exercises (empty if none).
  final List<ExerciseModel> favoriteExercises;

  /// Latest body metric (null if none).
  final BodyMetricModel? latestBodyMetric;

  /// Today's nutrition summary (null if no active plan).
  final NutritionSummary? todayNutrition;

  /// Recent completed workouts (empty if none).
  final List<WorkoutSessionModel> recentWorkouts;
}

/// State for the home dashboard.
sealed class HomeDashboardState {
  const HomeDashboardState();
}

class HomeDashboardLoading extends HomeDashboardState {
  const HomeDashboardLoading();
}

class HomeDashboardDataState extends HomeDashboardState {
  const HomeDashboardDataState(this.data);

  final HomeDashboardData data;
}

class HomeDashboardError extends HomeDashboardState {
  const HomeDashboardError(this.message);

  final String message;
}

/// Notifier that loads aggregated dashboard data.
///
/// Fetches data from multiple sources in parallel:
///   * Calendar (today's workout)
///   * Training plans (first plan)
///   * Recently viewed (recent exercises)
///   * Favorites (favorite exercises)
///   * Body metrics (latest measurement)
///   * Diet (today's nutrition)
///   * Workout history (recent sessions)
class HomeDashboardNotifier extends Notifier<HomeDashboardState> {
  @override
  HomeDashboardState build() {
    unawaited(_load());
    return const HomeDashboardLoading();
  }

  Future<void> _load() async {
    try {
      final calendarRepo = ref.read(calendarRepositoryProvider);
      final workoutRepo = ref.read(workoutRepositoryProvider);
      final trainingPlanRepo = ref.read(trainingPlanRepositoryProvider);
      final recentlyViewedRepo = ref.read(recentlyViewedRepositoryProvider);
      final favoriteRepo = ref.read(favoriteRepositoryProvider);
      final bodyMetricRepo = ref.read(bodyMetricRepositoryProvider);
      final dietRepo = ref.read(dietRepositoryProvider);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Fetch all data in parallel.
      final results = await Future.wait([
        calendarRepo.getForDate(today),
        trainingPlanRepo.allPlans(),
        recentlyViewedRepo.recent(limit: 6),
        favoriteRepo.all(limit: 6),
        bodyMetricRepo.latest(),
        dietRepo.getSummaryForDate(today),
        workoutRepo.completedSessions(),
      ]);

      if (!ref.mounted) return;

      final todayWorkout = results[0] as ScheduledWorkoutModel?;
      final plans = results[1] as List<TrainingPlanModel>;
      final recentExercises = results[2] as List<ExerciseModel>;
      final favoriteExercises = results[3] as List<ExerciseModel>;
      final latestBodyMetric = results[4] as BodyMetricModel?;
      final todayNutrition = results[5] as NutritionSummary;
      final recentWorkouts = results[6] as List<WorkoutSessionModel>;

      state = HomeDashboardDataState(HomeDashboardData(
        todayWorkout: todayWorkout,
        activePlan: plans.isEmpty ? null : plans.first,
        recentExercises: recentExercises,
        favoriteExercises: favoriteExercises,
        latestBodyMetric: latestBodyMetric,
        todayNutrition: todayNutrition,
        recentWorkouts: recentWorkouts.take(5).toList(),
      ));
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('HomeDashboard: load failed', e, st);
      state = HomeDashboardError(e.toString());
    }
  }

  /// Refreshes the dashboard data.
  Future<void> refresh() => _load();
}

/// Provider that exposes the [HomeDashboardNotifier].
final homeDashboardProvider =
    NotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
  HomeDashboardNotifier.new,
);
