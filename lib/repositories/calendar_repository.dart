import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/scheduled_workout_table.dart';
import '../utils/app_logger.dart';
import 'training_plan_repository.dart';

/// A scheduled workout enriched with its training-day name.
///
/// The UI needs both the schedule metadata (date, isCompleted, isRestDay)
/// and the human-readable day name. This model joins them so the calendar
/// doesn't have to issue a separate query per cell.
class ScheduledWorkoutModel {
  const ScheduledWorkoutModel({
    required this.id,
    required this.date,
    this.planDayId,
    this.planId,
    this.dayName,
    this.planName,
    required this.isCompleted,
    required this.isRestDay,
  });

  final int id;
  final DateTime date;
  final String? planDayId;
  final String? planId;
  final String? dayName;
  final String? planName;
  final bool isCompleted;
  final bool isRestDay;
}

/// Data-access layer for the training calendar.
///
/// Manages the mapping between calendar dates and training plan days.
/// Supports scheduling a workout on a date, marking it complete, and
/// querying workouts for a month / week.
class CalendarRepository {
  CalendarRepository(this._db, this._trainingPlanRepo);

  final AppDatabase _db;
  final TrainingPlanRepository _trainingPlanRepo;

  /// Schedules [planDayId] on [date], replacing any existing schedule for
  /// that date.
  Future<void> scheduleWorkout({
    required DateTime date,
    required String planId,
    required String planDayId,
  }) async {
    final normalizedDate = _normalizeDate(date);

    // Look up the day name for display.
    final plan = await _trainingPlanRepo.getPlan(planId);
    String? dayName;
    String? planName;
    if (plan != null) {
      planName = plan.name;
      for (final day in plan.days) {
        if (day.id == planDayId) {
          dayName = day.name;
          break;
        }
      }
    }

    // Delete any existing schedule for this date, then insert.
    await (_db.delete(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) => t.date.equals(normalizedDate)))
        .go();

    await _db.into(_db.scheduledWorkouts).insert(
          ScheduledWorkoutsCompanion.insert(
            date: normalizedDate,
            planDayId: Value(planDayId),
            planId: Value(planId),
            dayName: Value(dayName),
            planName: Value(planName),
          ),
        );
    AppLogger.d('Calendar: scheduled workout for $normalizedDate');
  }

  /// Marks [date] as a rest day, removing any scheduled workout.
  Future<void> markRestDay(DateTime date) async {
    final normalizedDate = _normalizeDate(date);

    await (_db.delete(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) => t.date.equals(normalizedDate)))
        .go();

    await _db.into(_db.scheduledWorkouts).insert(
          ScheduledWorkoutsCompanion.insert(
            date: normalizedDate,
            planDayId: const Value(null),
            planId: const Value(null),
            isRestDay: const Value(true),
          ),
        );
    AppLogger.d('Calendar: marked rest day for $normalizedDate');
  }

  /// Removes any schedule for [date] (workout or rest day).
  Future<void> clearDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    await (_db.delete(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) => t.date.equals(normalizedDate)))
        .go();
    AppLogger.d('Calendar: cleared $normalizedDate');
  }

  /// Toggles the completed state of the workout on [date].
  Future<void> toggleCompleted(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final row = await _getRaw(normalizedDate);
    if (row == null) return;

    await (_db.update(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) => t.id.equals(row.id)))
        .write(ScheduledWorkoutsCompanion(
      isCompleted: Value(!row.isCompleted),
    ));
  }

  /// Returns the scheduled workout for [date], or `null` if nothing is
  /// scheduled.
  Future<ScheduledWorkoutModel?> getForDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final row = await _getRaw(normalizedDate);
    if (row == null) return null;
    return _rowToModel(row);
  }

  /// Returns all scheduled workouts in the inclusive range [start, end].
  Future<List<ScheduledWorkoutModel>> getRange(
    DateTime start,
    DateTime end,
  ) async {
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);

    final rows = await (_db.select(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) =>
              t.date.isBetweenValues(normalizedStart, normalizedEnd))
          ..orderBy([(ScheduledWorkouts t) => OrderingTerm.asc(t.date)]))
        .get();

    return rows.map(_rowToModel).toList();
  }

  /// Returns all scheduled workouts for the month containing [date].
  Future<List<ScheduledWorkoutModel>> getMonth(DateTime date) async {
    final firstOfMonth = DateTime(date.year, date.month);
    final lastOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return getRange(firstOfMonth, lastOfMonth);
  }

  Future<ScheduledWorkoutRow?> _getRaw(DateTime date) async {
    final row = await (_db.select(_db.scheduledWorkouts)
          ..where((ScheduledWorkouts t) => t.date.equals(date))
        ..limit(1))
        .getSingleOrNull();
    return row;
  }

  ScheduledWorkoutModel _rowToModel(ScheduledWorkoutRow r) {
    return ScheduledWorkoutModel(
      id: r.id,
      date: r.date,
      planDayId: r.planDayId,
      planId: r.planId,
      dayName: r.dayName,
      planName: r.planName,
      isCompleted: r.isCompleted,
      isRestDay: r.isRestDay,
    );
  }

  /// Strips the time component so dates compare by day only.
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
