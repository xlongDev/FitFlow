import 'package:drift/drift.dart';

/// The `workout_sessions` table — records of completed or in-progress
/// workout sessions.
///
/// Each session represents one execution of a training day. It tracks the
/// start/end time, total volume, and completion state. The detailed per-set
/// records live in [SetRecords].
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Links to [ScheduledWorkouts.id]. Null for ad-hoc sessions.
  TextColumn get scheduledWorkoutId => text().nullable()();

  /// The training plan day id this session is based on.
  TextColumn get planDayId => text().nullable()();

  /// The plan id (denormalized).
  TextColumn get planId => text().nullable()();

  /// The plan name (denormalized for display).
  TextColumn get planName => text().nullable()();

  /// The day name (denormalized for display).
  TextColumn get dayName => text().nullable()();

  /// When the session started (ISO 8601).
  TextColumn get startedAt => text()();

  /// When the session ended (ISO 8601). Null while in progress.
  TextColumn get endedAt => text().nullable()();

  /// Total duration in seconds.
  IntColumn get durationSeconds => integer().nullable()();

  /// Total volume (sum of weight × reps) in kg.
  RealColumn get totalVolume => real().withDefault(const Constant(0))();

  /// Number of sets completed.
  IntColumn get setsCompleted => integer().withDefault(const Constant(0))();

  /// Whether the session is finished.
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The `set_records` table — individual set records within a session.
///
/// Each row records one set of an exercise: the weight lifted, reps
/// performed, and whether it's marked complete. Multiple sets per exercise
/// are allowed.
@DataClassName('SetRecordRow')
class SetRecords extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// The session this set belongs to.
  TextColumn get sessionId => text()();

  /// The exercise id from the exercise library.
  TextColumn get exerciseId => text()();

  /// The exercise name (denormalized for display).
  TextColumn get exerciseName => text()();

  /// Set number within this exercise (1-based).
  IntColumn get setNumber => integer().withDefault(const Constant(1))();

  /// Weight used in kg.
  RealColumn get weight => real().withDefault(const Constant(0))();

  /// Reps performed.
  IntColumn get reps => integer().withDefault(const Constant(0))();

  /// Whether this set is marked as completed.
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  /// When the set was recorded (ISO 8601).
  TextColumn get recordedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
