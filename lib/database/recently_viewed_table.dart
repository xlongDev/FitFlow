import 'package:drift/drift.dart';

/// The `recently_viewed` table — tracks the exercises the user has opened.
///
/// Each row records the exercise id and a timestamp. The same exercise can
/// appear multiple times (one row per view) so we can show a chronological
/// history; a unique index on (exerciseId, viewedAt) prevents exact
/// duplicates. The repository layer deduplicates for the "recent" list.
///
/// Kept separate from [Exercises] so the exercise library can be re-imported
/// without losing view history.
@DataClassName('RecentlyViewedRow')
class RecentlyViewed extends Table {
  /// Auto-incrementing primary key. When a column uses `autoIncrement()`,
  /// drift automatically treats it as the primary key — we must NOT also
  /// override `primaryKey`.
  IntColumn get id => integer().autoIncrement()();

  /// The exercise id this view refers to. Not a hard foreign key because the
  /// exercise library is a bundled asset that may be re-imported.
  TextColumn get exerciseId => text()();

  /// When the view happened (milliseconds since epoch).
  DateTimeColumn get viewedAt => dateTime().withDefault(currentDateAndTime)();
}
