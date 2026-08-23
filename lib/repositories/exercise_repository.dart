import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/exercise_parser.dart';
import '../database/exercise_table.dart';
import '../models/exercise_model.dart';
import '../utils/app_logger.dart';

/// Data-access layer for the exercise library.
///
/// Translates between [ExerciseModel] (the immutable domain model used by
/// the UI / Riverpod layer) and [ExerciseRow] (the drift row type stored in
/// SQLite). UI code never touches the database directly — it goes through
/// this repository via a Riverpod provider.
///
/// Responsibilities:
///   * First-launch import (parse bundled JSON → insert into SQLite).
///   * Idempotent re-import (skip if the table is already populated).
///   * CRUD + filtered / paginated queries.
///   * Conversion between model ↔ row (multilingual maps are JSON-encoded
///     in the DB because SQLite has no native map type).
class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Imports the bundled exercise dataset if the local table is empty.
  ///
  /// Returns the [ExerciseImportResult] from the parser. On subsequent app
  /// launches this is a no-op (the table is already populated) and returns
  /// `null` — callers can distinguish "first launch" from "already imported"
  /// by checking for `null`.
  Future<ExerciseImportResult?> importIfEmpty() async {
    final count = await _db.exercises.count().getSingle();
    if (count > 0) {
      AppLogger.i('ExerciseRepository: table already has $count rows, skipping import');
      return null;
    }

    AppLogger.i('ExerciseRepository: first launch, importing exercises.json');
    final result = await ExerciseParser.parseAsset();
    AppLogger.i('ExerciseRepository: parsed ${result.success} exercises '
        '(${result.failed} failed, ${result.duplicated} duplicated)');

    // Batch-insert for speed. 1300+ individual inserts would be slow.
    await _db.batch((Batch batch) {
      for (final m in result.exercises) {
        batch.insert(_db.exercises, _modelToCompanion(m));
      }
    });

    AppLogger.i('ExerciseRepository: inserted ${result.exercises.length} rows');
    return result;
  }

  /// Inserts a list of exercises directly (used by tests and future sync).
  ///
  /// Uses `mode: InsertMode.insertOrReplace` so re-inserting the same id
  /// updates rather than throwing.
  Future<void> insertAll(List<ExerciseModel> exercises) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.exercises,
        exercises.map(_modelToCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns the total number of exercises in the local database.
  Future<int> count() => _db.exercises.count().getSingle();

  /// Fetches a single exercise by id, or `null` if not found.
  Future<ExerciseModel?> getById(String id) async {
    final row = await (_db.select(_db.exercises)
          ..where((Exercises t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Fetches a page of exercises ordered by name.
  ///
  /// [limit] defaults to 50, [offset] to 0. Use these for paginated lists.
  Future<List<ExerciseModel>> getAll({
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await (_db.select(_db.exercises)
          ..orderBy([(Exercises t) => OrderingTerm(expression: t.name)])
          ..limit(limit, offset: offset))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Full-text search on exercise name (case-insensitive LIKE).
  ///
  /// For 1300 rows a `LIKE '%query%'` scan is fast enough. If the dataset
  /// grows significantly, consider adding an FTS5 virtual table.
  Future<List<ExerciseModel>> searchByName(String query) async {
    final rows = await (_db.select(_db.exercises)
          ..where((Exercises t) => t.name.like('%$query%'))
          ..orderBy([(Exercises t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Filters exercises by body part and/or equipment.
  ///
  /// Either argument may be `null` (meaning "no filter on this axis").
  Future<List<ExerciseModel>> filter({
    String? bodyPart,
    String? equipment,
    int limit = 50,
  }) async {
    final query = _db.select(_db.exercises);
    query.where((Exercises t) {
      final conditions = <Expression<bool>>[];
      if (bodyPart != null) {
        conditions.add(t.bodyPart.equals(bodyPart));
      }
      if (equipment != null) {
        conditions.add(t.equipment.equals(equipment));
      }
      return conditions.isEmpty ? const Constant(true) : conditions.reduce((a, b) => a & b);
    });
    query.orderBy([(Exercises t) => OrderingTerm(expression: t.name)]);
    query.limit(limit);
    final rows = await query.get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the distinct set of body parts present in the dataset.
  ///
  /// Used to populate the filter chips in the exercise library.
  Future<List<String>> distinctBodyParts() async {
    final query = _db.selectOnly(_db.exercises, distinct: true);
    query.addColumns([_db.exercises.bodyPart]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.exercises.bodyPart))
        .whereType<String>()
        .toList()
      ..sort();
  }

  /// Returns the distinct set of equipment types present in the dataset.
  Future<List<String>> distinctEquipment() async {
    final query = _db.selectOnly(_db.exercises, distinct: true);
    query.addColumns([_db.exercises.equipment]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.exercises.equipment))
        .whereType<String>()
        .toList()
      ..sort();
  }

  // ---------------------------------------------------------------------------
  // Model ↔ Row conversion
  // ---------------------------------------------------------------------------

  ExercisesCompanion _modelToCompanion(ExerciseModel m) {
    return ExercisesCompanion.insert(
      id: m.id,
      name: m.name,
      category: m.category,
      bodyPart: Value(m.bodyPart),
      equipment: Value(m.equipment),
      instructions: jsonEncode(m.instructions),
      instructionSteps: jsonEncode(m.instructionSteps),
      muscleGroup: Value(m.muscleGroup),
      secondaryMuscles: Value(jsonEncode(m.secondaryMuscles)),
      target: Value(m.target),
      mediaId: m.mediaId,
      image: m.image,
      gifUrl: m.gifUrl,
      attribution: m.attribution,
      createdAt: m.createdAt,
    );
  }

  ExerciseModel _rowToModel(ExerciseRow r) {
    return ExerciseModel(
      id: r.id,
      name: r.name,
      category: r.category,
      bodyPart: r.bodyPart,
      equipment: r.equipment,
      instructions: _decodeMap(r.instructions),
      instructionSteps: _decodeSteps(r.instructionSteps),
      muscleGroup: r.muscleGroup,
      secondaryMuscles: _decodeList(r.secondaryMuscles),
      target: r.target,
      mediaId: r.mediaId,
      image: r.image,
      gifUrl: r.gifUrl,
      attribution: r.attribution,
      createdAt: r.createdAt,
    );
  }

  Map<String, String> _decodeMap(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, List<String>> _decodeSteps(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) {
      final list = v is List ? v : <String>[];
      return MapEntry(k, list.cast<String>());
    });
  }

  List<String> _decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <String>[];
    return decoded.map((e) => e.toString()).toList();
  }
}
