import 'package:drift/drift.dart';

/// The `training_plans` table — top-level training plans.
///
/// Each plan contains one or more [TrainingDays] and is owned by the user.
/// Kept separate from the exercise library so plans survive re-imports.
@DataClassName('TrainingPlanRow')
class TrainingPlans extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User-visible plan name.
  TextColumn get name => text()();

  /// Optional description.
  TextColumn get description => text().withDefault(const Constant(''))();

  /// User's goal (e.g. "增肌", "减脂").
  TextColumn get goal => text().withDefault(const Constant(''))();

  /// Number of training days per week.
  IntColumn get daysPerWeek =>
      integer().withDefault(const Constant(3))();

  /// ISO 8601 creation timestamp.
  TextColumn get createdAt => text()();

  /// ISO 8601 last-update timestamp.
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The `training_days` table — days within a plan.
@DataClassName('TrainingDayRow')
class TrainingDays extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// The plan this day belongs to.
  TextColumn get planId => text()();

  /// Display name (e.g. "Push", "Pull", "Day 1").
  TextColumn get name => text()();

  /// Sort order within the plan (0-based).
  IntColumn get dayIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The `training_exercises` table — exercise entries within a day.
@DataClassName('TrainingExerciseRow')
class TrainingExercises extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// The day this exercise belongs to.
  TextColumn get dayId => text()();

  /// The referenced exercise id from the exercise library.
  TextColumn get exerciseId => text()();

  /// Denormalized exercise name for display without a join.
  TextColumn get exerciseName => text()();

  /// Number of sets.
  IntColumn get sets => integer().withDefault(const Constant(3))();

  /// Reps per set (string to support "8-12" or "AMRAP").
  TextColumn get reps => text().withDefault(const Constant('8'))();

  /// Weight in kg.
  RealColumn get weight => real().withDefault(const Constant(0))();

  /// Rest time between sets in seconds.
  IntColumn get restSeconds =>
      integer().withDefault(const Constant(90))();

  /// Sort order within the day.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Optional user notes.
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
