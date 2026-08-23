import 'package:drift/drift.dart';

/// The `scheduled_workouts` table — maps a calendar date to a training
/// plan day.
///
/// Each row records that the user plans to do [planDayId] (a [TrainingDays]
/// row) on [date]. A date can have at most one scheduled workout — if the
/// user wants to do two sessions in a day, they should create a combined
/// training day.
///
/// [isCompleted] tracks whether the workout was actually done. This is a
/// separate flag (rather than a separate "completed_at" column) so the user
/// can mark a workout complete and later un-mark it without losing the
/// schedule.
///
/// [isRestDay] marks a date as a rest day — no workout is scheduled, and the
/// UI shows a distinct "Rest" indicator. When [isRestDay] is true,
/// [planDayId] should be null.
@DataClassName('ScheduledWorkoutRow')
class ScheduledWorkouts extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The scheduled date (day only — time component is ignored).
  DateTimeColumn get date => dateTime()();

  /// The training plan day to do on this date. Null when [isRestDay] is
  /// true.
  TextColumn get planDayId => text().nullable()();

  /// The plan id (denormalized for quick lookup without a join).
  TextColumn get planId => text().nullable()();

  /// The training day name (denormalized for display without a join).
  TextColumn get dayName => text().nullable()();

  /// The plan name (denormalized for display without a join).
  TextColumn get planName => text().nullable()();

  /// Whether the workout has been completed.
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  /// Whether this is a rest day (no workout).
  BoolColumn get isRestDay =>
      boolean().withDefault(const Constant(false))();
}
