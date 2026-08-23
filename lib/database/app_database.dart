import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../utils/app_logger.dart';
import 'body_metric_table.dart';
import 'diet_table.dart';
import 'exercise_table.dart';
import 'favorites_table.dart';
import 'recently_viewed_table.dart';
import 'scheduled_workout_table.dart';
import 'training_plan_table.dart';
import 'workout_session_table.dart';

part 'app_database.g.dart';

/// The app's local SQLite database, built on drift.
///
/// Holds the exercise library and (in later phases) favorites, training
/// plans, diet records, body metrics, and settings. All persistence flows
/// through repositories — UI code never touches this class directly.
///
/// Schema migrations are handled by drift's [MigrationStrategy]. When adding
/// a new table in a future phase, bump [schemaVersion] and add an
/// `if (from < k)` block in [onUpgrade].
@DriftDatabase(
  tables: [
    Exercises,
    RecentlyViewed,
    Favorites,
    TrainingPlans,
    TrainingDays,
    TrainingExercises,
    ScheduledWorkouts,
    WorkoutSessions,
    SetRecords,
    DietRecords,
    DietPlans,
    BodyMetrics,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// For tests: inject a custom [QueryExecutor] (e.g. in-memory sqlite).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          AppLogger.i('Database: creating schema v$schemaVersion');
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          AppLogger.i('Database: upgrading schema v$from → v$to');
          // Phase 4: added the recently_viewed table.
          if (from < 2) {
            await m.createTable(recentlyViewed);
          }
          // Phase 5: added the favorites table.
          if (from < 3) {
            await m.createTable(favorites);
          }
          // Phase 6: added training plan tables.
          if (from < 4) {
            await m.createTable(trainingPlans);
            await m.createTable(trainingDays);
            await m.createTable(trainingExercises);
          }
          // Phase 7: added the scheduled_workouts table.
          if (from < 5) {
            await m.createTable(scheduledWorkouts);
          }
          // Phase 8: added workout session tables.
          if (from < 6) {
            await m.createTable(workoutSessions);
            await m.createTable(setRecords);
          }
          // Phase 9: added diet tables.
          if (from < 7) {
            await m.createTable(dietRecords);
            await m.createTable(dietPlans);
          }
          // Phase 10: added body metrics table.
          if (from < 8) {
            await m.createTable(bodyMetrics);
          }
        },
        beforeOpen: (details) async {
          // Enable foreign keys for referential integrity.
          await customStatement('PRAGMA foreign_keys = ON');
          // Enable WAL mode for better concurrent read performance.
          // This may fail on in-memory databases (used in tests) — that's OK.
          try {
            await customStatement('PRAGMA journal_mode = WAL');
          } catch (_) {
            // WAL mode not supported (e.g. in-memory database) — fall back
            // to the default journal mode.
          }
        },
      );

  /// Creates the drift [QueryExecutor] via drift_flutter, which handles
  /// platform-specific sqlite3 library loading and file placement.
  ///
  /// The database file lives in the app's documents directory as
  /// `fitness_app.db`.
  static QueryExecutor _open() {
    return driftDatabase(
      name: 'fitness_app.db',
    );
  }
}
