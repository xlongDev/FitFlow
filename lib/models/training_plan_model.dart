import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_plan_model.freezed.dart';
part 'training_plan_model.g.dart';

/// A user-created training plan (e.g. "Push / Pull / Legs", "Upper / Lower").
///
/// A plan contains one or more [TrainingDayModel]s, each of which contains
/// one or more [TrainingExerciseModel]s. This is the top-level model — the
/// repository loads the full tree when a plan is opened.
@freezed
abstract class TrainingPlanModel with _$TrainingPlanModel {
  const factory TrainingPlanModel({
    /// Server-assigned id (UUID). Acts as the primary key.
    required String id,

    /// User-visible plan name (e.g. "Push Pull Legs").
    required String name,

    /// Optional description / notes.
    @Default('') String description,

    /// The user's goal for this plan (e.g. "增肌", "减脂", "塑形").
    @Default('') String goal,

    /// Number of training days per week (e.g. 3, 4, 5).
    @Default(3) int daysPerWeek,

    /// The days in this plan, ordered by [TrainingDayModel.dayIndex].
    @Default(<TrainingDayModel>[]) List<TrainingDayModel> days,

    /// ISO 8601 timestamp of creation.
    required String createdAt,

    /// ISO 8601 timestamp of last update.
    required String updatedAt,
  }) = _TrainingPlanModel;

  factory TrainingPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanModelFromJson(json);
}

/// A single training day within a plan (e.g. "Push Day", "Pull Day").
@freezed
abstract class TrainingDayModel with _$TrainingDayModel {
  const factory TrainingDayModel({
    /// Server-assigned id (UUID).
    required String id,

    /// The plan this day belongs to.
    required String planId,

    /// Display name (e.g. "Push", "Pull", "Legs", "Day 1").
    required String name,

    /// Sort order within the plan (0-based).
    @Default(0) int dayIndex,

    /// The exercises in this day, ordered by [TrainingExerciseModel.sortOrder].
    @Default(<TrainingExerciseModel>[]) List<TrainingExerciseModel> exercises,
  }) = _TrainingDayModel;

  factory TrainingDayModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingDayModelFromJson(json);
}

/// A single exercise entry within a training day.
///
/// Configures how an exercise is performed: sets, reps, weight, rest, etc.
/// References an [ExerciseModel] by id.
@freezed
abstract class TrainingExerciseModel with _$TrainingExerciseModel {
  const factory TrainingExerciseModel({
    /// Server-assigned id (UUID).
    required String id,

    /// The day this exercise belongs to.
    required String dayId,

    /// The referenced exercise id from the exercise library.
    required String exerciseId,

    /// The exercise name (denormalized for display without a join).
    required String exerciseName,

    /// Number of sets (e.g. 4).
    @Default(3) int sets,

    /// Number of reps per set (e.g. 8). Stored as string to support ranges
    /// like "8-12" or "AMRAP".
    @Default('8') String reps,

    /// Weight in kg (e.g. 75.0). 0 means body weight.
    @Default(0) double weight,

    /// Rest time between sets in seconds (e.g. 90).
    @Default(90) int restSeconds,

    /// Sort order within the day (0-based).
    @Default(0) int sortOrder,

    /// Optional user notes (e.g. "Slow eccentric", "Drop set on last set").
    @Default('') String notes,
  }) = _TrainingExerciseModel;

  factory TrainingExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingExerciseModelFromJson(json);
}
