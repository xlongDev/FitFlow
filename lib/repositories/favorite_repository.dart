import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/favorites_table.dart';
import '../models/exercise_model.dart';
import '../utils/app_logger.dart';
import 'exercise_repository.dart';

/// Data-access layer for the user's favorite exercises.
///
/// Translates between [ExerciseModel] (the immutable domain model used by
/// the UI / Riverpod layer) and [FavoriteRow] (the drift row type stored in
/// SQLite). UI code never touches the database directly — it goes through
/// this repository via a Riverpod provider.
///
/// Responsibilities:
///   * Add / remove favorites (idempotent — re-favoriting is a no-op).
///   * Query whether an exercise is favorited.
///   * List all favorites as [ExerciseModel]s, newest-first.
///   * Search favorites by name.
class FavoriteRepository {
  FavoriteRepository(this._db, this._exerciseRepo);

  final AppDatabase _db;
  final ExerciseRepository _exerciseRepo;

  /// Adds [exerciseId] to favorites.
  ///
  /// Uses `InsertMode.insertOrIgnore` so favoriting an already-favorited
  /// exercise is a no-op rather than throwing.
  Future<void> add(String exerciseId) async {
    await _db.into(_db.favorites).insert(
          FavoritesCompanion.insert(exerciseId: exerciseId),
          mode: InsertMode.insertOrIgnore,
        );
    AppLogger.d('Favorite: added $exerciseId');
  }

  /// Removes [exerciseId] from favorites.
  ///
  /// Returns the number of rows deleted (0 if it wasn't favorited).
  Future<int> remove(String exerciseId) async {
    final count = await (_db.delete(_db.favorites)
          ..where((Favorites t) => t.exerciseId.equals(exerciseId)))
        .go();
    AppLogger.d('Favorite: removed $exerciseId ($count rows)');
    return count;
  }

  /// Toggles the favorite state of [exerciseId].
  ///
  /// Returns `true` if the exercise is now favorited, `false` if it was
  /// un-favorited.
  Future<bool> toggle(String exerciseId) async {
    final isFav = await isFavorite(exerciseId);
    if (isFav) {
      await remove(exerciseId);
      return false;
    } else {
      await add(exerciseId);
      return true;
    }
  }

  /// Returns `true` if [exerciseId] is in the user's favorites.
  Future<bool> isFavorite(String exerciseId) async {
    final count = await (_db.select(_db.favorites)
          ..where((Favorites t) => t.exerciseId.equals(exerciseId)))
        .get();
    return count.isNotEmpty;
  }

  /// Returns all favorited exercises, newest-first.
  ///
  /// [limit] caps the result count — defaults to 200, enough for the
  /// favorites page without loading an unbounded list.
  Future<List<ExerciseModel>> all({int limit = 200}) async {
    final rows = await (_db.select(_db.favorites)
          ..orderBy([(Favorites t) => OrderingTerm.desc(t.favoritedAt)])
          ..limit(limit))
        .get();

    final exercises = <ExerciseModel>[];
    for (final row in rows) {
      final exercise = await _exerciseRepo.getById(row.exerciseId);
      if (exercise != null) {
        exercises.add(exercise);
      }
    }
    return exercises;
  }

  /// Returns the set of all favorited exercise ids.
  ///
  /// Used by the library / detail page to render the favorite icon state
  /// without loading full exercise models.
  Future<Set<String>> favoriteIds() async {
    final rows = await _db.select(_db.favorites).get();
    return rows.map((r) => r.exerciseId).toSet();
  }

  /// Searches favorites by exercise name (case-insensitive).
  Future<List<ExerciseModel>> search(String query) async {
    final allFavorites = await all();
    final lowerQuery = query.toLowerCase();
    return allFavorites
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Clears all favorites.
  Future<void> clear() async {
    await _db.delete(_db.favorites).go();
    AppLogger.i('Favorite: cleared all');
  }
}
