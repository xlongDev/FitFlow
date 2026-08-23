import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exercise_model.dart';
import '../utils/app_logger.dart';

/// Result of a single import run.
///
/// Aggregates counts so the UI can show a summary ("Imported 1320 of 1324
/// exercises, 4 skipped, 0 duplicates") and so tests can assert on the
/// parser's resilience to bad data.
class ExerciseImportResult {
  const ExerciseImportResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.duplicated,
    required this.exercises,
  });

  /// Total records encountered in the source JSON.
  final int total;

  /// Records that parsed successfully and passed validation.
  final int success;

  /// Records skipped due to malformed data or missing required fields.
  final int failed;

  /// Records skipped because an earlier record had the same id.
  final int duplicated;

  /// The successfully parsed exercises, ready to insert into the database.
  final List<ExerciseModel> exercises;

  @override
  String toString() =>
      'ExerciseImportResult(total: $total, success: $success, '
      'failed: $failed, duplicated: $duplicated)';
}

/// Thrown when the bundled `exercises.json` cannot be loaded or decoded.
class ExerciseParserException implements Exception {
  const ExerciseParserException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'ExerciseParserException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Parses the bundled `exercises.json` into a list of [ExerciseModel]s.
///
/// The parser is deliberately defensive: a single bad record must never
/// abort the whole import. Each record is validated individually; failures
/// are logged and counted in [ExerciseImportResult.failed]. Duplicate ids
/// are detected and counted in [ExerciseImportResult.duplicated].
///
/// Usage:
/// ```dart
/// final result = await ExerciseParser.parseAsset();
/// // result.exercises → List<ExerciseModel>
/// ```
class ExerciseParser {
  ExerciseParser._();

  /// Loads `lib/assets/exercises.json` from the app bundle and parses it.
  ///
  /// Throws [ExerciseParserException] if the asset is missing or the
  /// top-level JSON is not an array. Individual record failures are
  /// swallowed and counted in the result.
  static Future<ExerciseImportResult> parseAsset() async {
    final String raw;
    try {
      raw = await rootBundle.loadString('lib/assets/exercises.json');
    } catch (e, st) {
      AppLogger.e('Failed to load exercises.json asset', e, st);
      throw ExerciseParserException(
        'Could not load exercises.json from app bundle',
        cause: e,
      );
    }

    return parseJsonString(raw);
  }

  /// Parses a JSON string containing an array of exercise records.
  ///
  /// Exposed for testing — production code should use [parseAsset].
  static ExerciseImportResult parseJsonString(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e, st) {
      AppLogger.e('exercises.json is not valid JSON', e, st);
      throw ExerciseParserException(
        'exercises.json is not valid JSON',
        cause: e,
      );
    }

    if (decoded is! List) {
      throw ExerciseParserException(
        'Expected a JSON array at the top level, got ${decoded.runtimeType}',
      );
    }

    return _parseList(decoded.cast<Map<String, dynamic>>());
  }

  static ExerciseImportResult _parseList(List<Map<String, dynamic>> rawList) {
    final seenIds = <String>{};
    final exercises = <ExerciseModel>[];
    var failed = 0;
    var duplicated = 0;

    for (var i = 0; i < rawList.length; i++) {
      final record = rawList[i];
      try {
        final exercise = _parseRecord(record, i);
        if (seenIds.contains(exercise.id)) {
          duplicated++;
          AppLogger.w('Duplicate exercise id skipped: ${exercise.id}');
          continue;
        }
        seenIds.add(exercise.id);
        exercises.add(exercise);
      } catch (e, st) {
        failed++;
        AppLogger.w('Failed to parse exercise at index $i: $e', e, st);
      }
    }

    return ExerciseImportResult(
      total: rawList.length,
      success: exercises.length,
      failed: failed,
      duplicated: duplicated,
      exercises: exercises,
    );
  }

  /// Parses and validates a single record.
  ///
  /// Throws [ExerciseParserException] on any structural problem so the caller
  /// can count it as a failure. Required fields: id, name, bodyPart,
  /// equipment, instructions, instructionSteps, muscleGroup, target, mediaId,
  /// image, gifUrl, attribution, createdAt.
  static ExerciseModel _parseRecord(Map<String, dynamic> record, int index) {
    final id = record['id'];
    if (id is! String || id.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'id', 'non-empty string', id));
    }

    final name = record['name'];
    if (name is! String || name.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'name', 'non-empty string', name));
    }

    final bodyPart = record['body_part'];
    if (bodyPart is! String || bodyPart.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'body_part', 'non-empty string', bodyPart));
    }

    final equipment = record['equipment'];
    if (equipment is! String || equipment.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'equipment', 'non-empty string', equipment));
    }

    final instructions = record['instructions'];
    if (instructions is! Map) {
      throw ExerciseParserException(_fieldError(index, 'instructions', 'object', instructions));
    }

    final instructionSteps = record['instruction_steps'];
    if (instructionSteps is! Map) {
      throw ExerciseParserException(_fieldError(index, 'instruction_steps', 'object', instructionSteps));
    }

    final muscleGroup = record['muscle_group'];
    if (muscleGroup is! String || muscleGroup.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'muscle_group', 'non-empty string', muscleGroup));
    }

    final target = record['target'];
    if (target is! String || target.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'target', 'non-empty string', target));
    }

    final mediaId = record['media_id'];
    if (mediaId is! String || mediaId.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'media_id', 'non-empty string', mediaId));
    }

    final image = record['image'];
    if (image is! String || image.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'image', 'non-empty string', image));
    }

    final gifUrl = record['gif_url'];
    if (gifUrl is! String || gifUrl.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'gif_url', 'non-empty string', gifUrl));
    }

    final attribution = record['attribution'];
    if (attribution is! String || attribution.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'attribution', 'non-empty string', attribution));
    }

    final createdAt = record['created_at'];
    if (createdAt is! String || createdAt.isEmpty) {
      throw ExerciseParserException(_fieldError(index, 'created_at', 'non-empty string', createdAt));
    }

    // Coerce map types — the source data uses String keys and String / List
    // values, but JSON decoding produces Map<String, dynamic>.
    final instructionsMap = instructions.map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    );
    final stepsMap = instructionSteps.map((k, v) {
      final list = v is List ? v : <String>[];
      return MapEntry(k.toString(), list.cast<String>());
    });

    final secondaryMuscles = record['secondary_muscles'];
    final secondaryMusclesList = secondaryMuscles is List
        ? secondaryMuscles.map((e) => e.toString()).toList()
        : <String>[];

    return ExerciseModel(
      id: id,
      name: name,
      category: (record['category'] as String?) ?? bodyPart,
      bodyPart: bodyPart,
      equipment: equipment,
      instructions: instructionsMap,
      instructionSteps: stepsMap,
      muscleGroup: muscleGroup,
      secondaryMuscles: secondaryMusclesList,
      target: target,
      mediaId: mediaId,
      image: image,
      gifUrl: gifUrl,
      attribution: attribution,
      createdAt: createdAt,
    );
  }

  static String _fieldError(
    int index,
    String field,
    String expected,
    Object? actual,
  ) {
    return 'Record $index: field "$field" expected $expected, '
        'got ${actual.runtimeType}';
  }
}
