import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_session_model.freezed.dart';
part 'workout_session_model.g.dart';

/// A single workout session — one execution of a training day.
///
/// Created when the user starts a workout from the calendar. Tracks the
/// start / end time, the planned vs actual sets, and the overall completion
/// state. Each session contains one or more [SetRecordModel]s.
@freezed
abstract class WorkoutSessionModel with _$WorkoutSessionModel {
  const factory WorkoutSessionModel({
    /// UUID primary key.
    required String id,

    /// The scheduled workout id (links to [ScheduledWorkouts]).
    /// Null for ad-hoc sessions not tied to a calendar entry.
    String? scheduledWorkoutId,

    /// The training plan day id this session is based on.
    String? planDayId,

    /// The plan id (denormalized).
    String? planId,

    /// The plan name (denormalized for display).
    String? planName,

    /// The day name (denormalized for display).
    String? dayName,

    /// When the session started (ISO 8601).
    required String startedAt,

    /// When the session ended (ISO 8601). Null while in progress.
    String? endedAt,

    /// Total duration in seconds (endedAt - startedAt). Null while in progress.
    int? durationSeconds,

    /// Total volume (sum of weight × reps across all sets) in kg.
    @Default(0) double totalVolume,

    /// Number of sets completed.
    @Default(0) int setsCompleted,

    /// Whether the session is finished.
    @Default(false) bool isCompleted,

    /// The sets recorded during this session.
    @Default(<SetRecordModel>[]) List<SetRecordModel> sets,
  }) = _WorkoutSessionModel;

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionModelFromJson(json);
}

/// A single set record within a workout session.
///
/// Records the actual weight lifted and reps performed for one set of an
/// exercise. The user can log multiple sets per exercise.
@freezed
abstract class SetRecordModel with _$SetRecordModel {
  const factory SetRecordModel({
    /// UUID primary key.
    required String id,

    /// The session this set belongs to.
    required String sessionId,

    /// The exercise id from the exercise library.
    required String exerciseId,

    /// The exercise name (denormalized for display).
    required String exerciseName,

    /// Set number within this exercise (1-based).
    @Default(1) int setNumber,

    /// Weight used in kg.
    @Default(0) double weight,

    /// Reps performed.
    @Default(0) int reps,

    /// Whether this set is marked as completed.
    @Default(false) bool isCompleted,

    /// When the set was recorded (ISO 8601).
    required String recordedAt,
  }) = _SetRecordModel;

  factory SetRecordModel.fromJson(Map<String, dynamic> json) =>
      _$SetRecordModelFromJson(json);
}
