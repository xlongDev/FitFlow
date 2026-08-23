import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

/// A fitness exercise record parsed from the bundled `exercises.json`.
///
/// This is the immutable, serializable representation used by the JSON parser
/// and the Riverpod layer. The drift database layer has its own table
/// ([Exercises]) that mirrors these fields — the two are deliberately kept
/// separate so the model can evolve (or be replaced by a DTO) without
/// touching the database schema, and vice-versa.
///
/// Field naming follows the source dataset's snake_case convention so
/// `fromJson` works without manual mapping. Use [name] / [bodyPart] /
/// [equipment] / [muscleGroup] / [target] for display.
@freezed
abstract class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    /// Zero-padded 4-digit id (e.g. "0001"). Acts as the primary key.
    required String id,

    /// Full exercise name (e.g. "3/4 sit-up").
    required String name,

    /// Body-part category (mirrors [bodyPart] in the source data).
    required String category,

    /// Body part targeted (e.g. "chest", "back", "upper arms").
    required String bodyPart,

    /// Required equipment (e.g. "dumbbell", "body weight").
    required String equipment,

    /// Multilingual full instructions (single string per language).
    ///
    /// Keys are ISO 639-1 codes (en, zh, es, it, tr, ru, hi, pl, ko, fr).
    required Map<String, String> instructions,

    /// Multilingual step-by-step instructions (array of strings per language).
    required Map<String, List<String>> instructionSteps,

    /// Primary synergist muscle group.
    required String muscleGroup,

    /// Additional muscles involved.
    @Default(<String>[]) List<String> secondaryMuscles,

    /// Primary target muscle (e.g. "biceps", "abs").
    required String target,

    /// Original media reference id (e.g. "2gPfomN").
    required String mediaId,

    /// Path to the 180x180 thumbnail (e.g. "images/0001-2gPfomN.jpg").
    required String image,

    /// Path to the 180x180 animation GIF (e.g. "videos/0001-2gPfomN.gif").
    required String gifUrl,

    /// Media copyright notice.
    required String attribution,

    /// ISO 8601 timestamp of record creation in the source dataset.
    required String createdAt,
  }) = _ExerciseModel;

  /// Parses an [ExerciseModel] from the JSON map produced by the dataset.
  ///
  /// Field names match the source dataset's snake_case keys.
  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);
}
