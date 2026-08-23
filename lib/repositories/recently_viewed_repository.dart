import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/exercise_model.dart';
import '../utils/app_logger.dart';
import 'exercise_repository.dart';

/// Data-access layer for the "recently viewed" history.
///
/// Records every exercise the user opens and provides a deduplicated,
/// most-recent-first list for the home screen / favorites page.
///
/// UI code never touches the database directly — it goes through this
/// repository via a Riverpod provider.
class RecentlyViewedRepository {
  RecentlyViewedRepository(this._db, this._exerciseRepo);

  final AppDatabase _db;
  final ExerciseRepository _exerciseRepo;

  /// Records that the user opened [exerciseId].
  ///
  /// Inserts a new row rather than updating an existing one so the full
  /// chronological history is preserved. The "recent" list is deduplicated
  /// by [recent].
  Future<void> recordView(String exerciseId) async {
    await _db.into(_db.recentlyViewed).insert(
          RecentlyViewedCompanion.insert(
            exerciseId: exerciseId,
          ),
        );
    AppLogger.d('RecentlyViewed: recorded view for $exerciseId');
  }

  /// Returns the most recently viewed exercises, deduplicated, newest first.
  ///
  /// [limit] defaults to 20 — enough for the home screen carousel without
  /// loading the entire history.
  Future<List<ExerciseModel>> recent({int limit = 20}) async {
    // Subquery: the latest view timestamp per exercise id.
    final latestPerExercise = _db.selectOnly(_db.recentlyViewed)
      ..addColumns([
        _db.recentlyViewed.exerciseId,
        _db.recentlyViewed.viewedAt.max(),
      ])
      ..groupBy([_db.recentlyViewed.exerciseId])
      ..orderBy([OrderingTerm.desc(_db.recentlyViewed.viewedAt.max())])
      ..limit(limit);

    final rows = await latestPerExercise.get();
    if (rows.isEmpty) return <ExerciseModel>[];

    // Fetch the full exercise models in the same order.
    final ids = rows
        .map((r) => r.read(_db.recentlyViewed.exerciseId))
        .whereType<String>()
        .toList();

    final exercises = <ExerciseModel>[];
    for (final id in ids) {
      final exercise = await _exerciseRepo.getById(id);
      if (exercise != null) {
        exercises.add(exercise);
      }
    }
    return exercises;
  }

  /// Clears the entire recently-viewed history.
  Future<void> clear() async {
    await _db.delete(_db.recentlyViewed).go();
    AppLogger.i('RecentlyViewed: cleared all history');
  }
}
