import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../repositories/body_metric_repository.dart';
import '../repositories/calendar_repository.dart';
import '../repositories/diet_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/recently_viewed_repository.dart';
import '../repositories/training_plan_repository.dart';
import '../repositories/workout_repository.dart';

/// Provides the singleton [AppDatabase] for the whole app.
///
/// Kept as a [Provider] (not a future provider) because drift opens the
/// database lazily on first query — there's no async work to await here.
/// The database is closed automatically when the app process dies; we don't
/// need an explicit dispose hook for that.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides the [ExerciseRepository], backed by [appDatabaseProvider].
///
/// UI / Riverpod layers depend on this, never on the database directly.
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExerciseRepository(db);
});

/// Provides the [RecentlyViewedRepository], backed by [appDatabaseProvider]
/// and [exerciseRepositoryProvider].
final recentlyViewedRepositoryProvider = Provider<RecentlyViewedRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  return RecentlyViewedRepository(db, exerciseRepo);
});

/// Provides the [FavoriteRepository], backed by [appDatabaseProvider]
/// and [exerciseRepositoryProvider].
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  return FavoriteRepository(db, exerciseRepo);
});

/// Provides the [TrainingPlanRepository], backed by [appDatabaseProvider].
final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrainingPlanRepository(db);
});

/// Provides the [CalendarRepository], backed by [appDatabaseProvider]
/// and [trainingPlanRepositoryProvider].
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final trainingPlanRepo = ref.watch(trainingPlanRepositoryProvider);
  return CalendarRepository(db, trainingPlanRepo);
});

/// Provides the [WorkoutRepository], backed by [appDatabaseProvider]
/// and [calendarRepositoryProvider].
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final calendarRepo = ref.watch(calendarRepositoryProvider);
  return WorkoutRepository(db, calendarRepo);
});

/// Provides the [DietRepository], backed by [appDatabaseProvider].
final dietRepositoryProvider = Provider<DietRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DietRepository(db);
});

/// Provides the [BodyMetricRepository], backed by [appDatabaseProvider].
final bodyMetricRepositoryProvider = Provider<BodyMetricRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BodyMetricRepository(db);
});

/// A throwaway provider used in tests to inject an in-memory database.
///
/// Production code should use [appDatabaseProvider]. Tests override this
/// with `overrideWith` and a [NativeDatabase.memory] backed [AppDatabase].
final testingDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override this in tests with an in-memory database');
});
