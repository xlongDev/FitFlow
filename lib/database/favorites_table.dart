import 'package:drift/drift.dart';

/// The `favorites` table — exercises the user has bookmarked.
///
/// Each row is a (exerciseId, favoritedAt) pair. An exercise is either
/// favorited or not — there's no "favorites count" or "favorite level".
/// The composite unique index on [exerciseId] prevents duplicate favorites;
/// the repository layer uses `insertOnConflict: ignore` so re-favoriting an
/// already-favorited exercise is a no-op.
///
/// Kept separate from [Exercises] so the exercise library can be re-imported
/// without losing favorites.
@DataClassName('FavoriteRow')
class Favorites extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The favorited exercise's id. Not a hard foreign key because the
  /// exercise library is a bundled asset that may be re-imported.
  TextColumn get exerciseId => text()();

  /// When the favorite was added (milliseconds since epoch).
  DateTimeColumn get favoritedAt => dateTime().withDefault(currentDateAndTime)();
}
