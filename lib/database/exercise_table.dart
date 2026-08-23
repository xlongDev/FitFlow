import 'package:drift/drift.dart';

/// The `exercises` table — the local cache of the bundled exercise library.
///
/// Mirrors [ExerciseModel] but is a drift row type so it can be queried
/// with SQL. Multilingual fields ([instructions], [instructionSteps]) are
/// stored as JSON-encoded TEXT columns because SQLite has no native map type;
/// they're decoded back to maps in the repository layer.
///
/// [bodyPart], [equipment], [muscleGroup], [target] are indexed because they
/// are the primary filter axes in the exercise library UI.
@DataClassName('ExerciseRow')
class Exercises extends Table {
  /// Zero-padded 4-digit id (e.g. "0001"). Primary key.
  TextColumn get id => text()();

  /// Full exercise name.
  TextColumn get name => text()();

  /// Body-part category.
  TextColumn get category => text()();

  /// Body part targeted (indexed for fast filtering).
  TextColumn get bodyPart => text().withDefault(const Constant(''))();

  /// Required equipment (indexed for fast filtering).
  TextColumn get equipment => text().withDefault(const Constant(''))();

  /// Multilingual full instructions, JSON-encoded.
  TextColumn get instructions => text()();

  /// Multilingual step-by-step instructions, JSON-encoded.
  TextColumn get instructionSteps => text()();

  /// Primary synergist muscle group (indexed).
  TextColumn get muscleGroup => text().withDefault(const Constant(''))();

  /// Additional muscles involved, JSON-encoded array.
  TextColumn get secondaryMuscles => text().withDefault(const Constant('[]'))();

  /// Primary target muscle (indexed).
  TextColumn get target => text().withDefault(const Constant(''))();

  /// Original media reference id.
  TextColumn get mediaId => text()();

  /// Path to the 180x180 thumbnail.
  TextColumn get image => text()();

  /// Path to the 180x180 animation GIF.
  TextColumn get gifUrl => text()();

  /// Media copyright notice.
  TextColumn get attribution => text()();

  /// ISO 8601 timestamp of record creation in the source dataset.
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Indexes declared separately so drift generates `CREATE INDEX` statements.
///
/// These columns back the most common filter / search queries in the
/// exercise library, so indexing them keeps the UI snappy with 1300+ rows.
// drift picks up indexes declared as top-level constants annotated with
// `@TableIndex`. We declare them inline via the table API instead for
// forward-compat with drift 2.34.
