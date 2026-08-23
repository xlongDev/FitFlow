import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/workout_session_table.dart';
import '../models/workout_session_model.dart';
import '../utils/app_logger.dart';
import 'calendar_repository.dart';

/// Data-access layer for workout sessions and set records.
///
/// Manages the lifecycle of a workout session: creating it when the user
/// starts a workout, recording sets during the workout, and finalizing it
/// (computing total volume, duration, completion) when the user finishes.
///
/// Also integrates with [CalendarRepository] — when a session tied to a
/// scheduled workout is completed, the calendar entry is marked complete.
class WorkoutRepository {
  WorkoutRepository(this._db, this._calendarRepo);

  final AppDatabase _db;
  final CalendarRepository _calendarRepo;

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  /// Starts a new workout session.
  ///
  /// If [scheduledWorkoutId] is provided, the session is linked to that
  /// calendar entry and inherits its plan / day metadata.
  Future<String> startSession({
    String? scheduledWorkoutId,
    String? planDayId,
    String? planId,
    String? planName,
    String? dayName,
  }) async {
    final id = _uuid();
    final now = DateTime.now().toIso8601String();

    await _db.into(_db.workoutSessions).insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            scheduledWorkoutId: Value(scheduledWorkoutId),
            planDayId: Value(planDayId),
            planId: Value(planId),
            planName: Value(planName),
            dayName: Value(dayName),
            startedAt: now,
          ),
        );
    AppLogger.i('Workout: started session $id');
    return id;
  }

  /// Finishes a session: sets end time, computes duration and total volume,
  /// marks as completed, and (if linked) marks the calendar entry complete.
  Future<void> finishSession(String sessionId) async {
    final now = DateTime.now();
    final session = await getSession(sessionId);
    if (session == null) return;

    final startedAt = DateTime.parse(session.startedAt);
    final duration = now.difference(startedAt).inSeconds;

    // Compute total volume from completed sets.
    final sets = await getSets(sessionId);
    final totalVolume = sets
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.weight * s.reps);
    final setsCompleted = sets.where((s) => s.isCompleted).length;

    await (_db.update(_db.workoutSessions)
          ..where((WorkoutSessions t) => t.id.equals(sessionId)))
        .write(
      WorkoutSessionsCompanion(
        endedAt: Value(now.toIso8601String()),
        durationSeconds: Value(duration),
        totalVolume: Value(totalVolume),
        setsCompleted: Value(setsCompleted),
        isCompleted: const Value(true),
      ),
    );

    // If linked to a calendar entry, mark it complete.
    if (session.scheduledWorkoutId != null) {
      // Look up the scheduled workout to get its date.
      final scheduled = await _calendarRepo.getForDate(
        DateTime.parse(session.startedAt),
      );
      if (scheduled != null && !scheduled.isCompleted) {
        await _calendarRepo.toggleCompleted(scheduled.date);
      }
    }

    AppLogger.i('Workout: finished session $sessionId '
        '(duration: ${duration}s, volume: ${totalVolume}kg, sets: $setsCompleted)');
  }

  /// Abandons a session, deleting it and its sets entirely.
  Future<void> abandonSession(String sessionId) async {
    // Delete all sets first (no cascade on this table).
    await (_db.delete(_db.setRecords)
          ..where((SetRecords t) => t.sessionId.equals(sessionId)))
        .go();
    // Then delete the session.
    await (_db.delete(_db.workoutSessions)
          ..where((WorkoutSessions t) => t.id.equals(sessionId)))
        .go();
    AppLogger.i('Workout: abandoned session $sessionId');
  }

  // ---------------------------------------------------------------------------
  // Session queries
  // ---------------------------------------------------------------------------

  /// Loads a session with all its sets.
  Future<WorkoutSessionModel?> getSession(String sessionId) async {
    final row = await (_db.select(_db.workoutSessions)
          ..where((WorkoutSessions t) => t.id.equals(sessionId)))
        .getSingleOrNull();
    if (row == null) return null;

    final sets = await getSets(sessionId);
    return _rowToSession(row, sets);
  }

  /// Returns all completed sessions, newest first.
  Future<List<WorkoutSessionModel>> completedSessions({int limit = 50}) async {
    final rows = await (_db.select(_db.workoutSessions)
          ..where((WorkoutSessions t) => t.isCompleted.equals(true))
          ..orderBy([(WorkoutSessions t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .get();

    final sessions = <WorkoutSessionModel>[];
    for (final row in rows) {
      final sets = await getSets(row.id);
      sessions.add(_rowToSession(row, sets));
    }
    return sessions;
  }

  // ---------------------------------------------------------------------------
  // Set records
  // ---------------------------------------------------------------------------

  /// Adds a set record to a session.
  Future<String> addSet({
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    required int setNumber,
    required double weight,
    required int reps,
  }) async {
    final id = _uuid();
    await _db.into(_db.setRecords).insert(
          SetRecordsCompanion.insert(
            id: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            setNumber: Value(setNumber),
            weight: Value(weight),
            reps: Value(reps),
            recordedAt: DateTime.now().toIso8601String(),
          ),
        );
    return id;
  }

  /// Updates a set record.
  Future<void> updateSet(SetRecordModel set) async {
    await (_db.update(_db.setRecords)
          ..where((SetRecords t) => t.id.equals(set.id)))
        .write(
      SetRecordsCompanion(
        weight: Value(set.weight),
        reps: Value(set.reps),
        isCompleted: Value(set.isCompleted),
      ),
    );
  }

  /// Toggles a set's completion state.
  Future<void> toggleSetCompletion(String setId) async {
    final row = await (_db.select(_db.setRecords)
          ..where((SetRecords t) => t.id.equals(setId)))
        .getSingleOrNull();
    if (row == null) return;

    await (_db.update(_db.setRecords)
          ..where((SetRecords t) => t.id.equals(setId)))
        .write(
      SetRecordsCompanion(
        isCompleted: Value(!row.isCompleted),
      ),
    );
  }

  /// Removes a set record.
  Future<void> removeSet(String setId) async {
    await (_db.delete(_db.setRecords)
          ..where((SetRecords t) => t.id.equals(setId)))
        .go();
  }

  /// Returns all sets for a session, ordered by set number.
  Future<List<SetRecordModel>> getSets(String sessionId) async {
    final rows = await (_db.select(_db.setRecords)
          ..where((SetRecords t) => t.sessionId.equals(sessionId))
          ..orderBy([(SetRecords t) => OrderingTerm.asc(t.setNumber)]))
        .get();
    return rows.map(_rowToSet).toList();
  }

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  WorkoutSessionModel _rowToSession(
    WorkoutSessionRow r,
    List<SetRecordModel> sets,
  ) {
    return WorkoutSessionModel(
      id: r.id,
      scheduledWorkoutId: r.scheduledWorkoutId,
      planDayId: r.planDayId,
      planId: r.planId,
      planName: r.planName,
      dayName: r.dayName,
      startedAt: r.startedAt,
      endedAt: r.endedAt,
      durationSeconds: r.durationSeconds,
      totalVolume: r.totalVolume,
      setsCompleted: r.setsCompleted,
      isCompleted: r.isCompleted,
      sets: sets,
    );
  }

  SetRecordModel _rowToSet(SetRecordRow r) {
    return SetRecordModel(
      id: r.id,
      sessionId: r.sessionId,
      exerciseId: r.exerciseId,
      exerciseName: r.exerciseName,
      setNumber: r.setNumber,
      weight: r.weight,
      reps: r.reps,
      isCompleted: r.isCompleted,
      recordedAt: r.recordedAt,
    );
  }

  String _uuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final hex = now.toRadixString(16).padLeft(16, '0');
    return 'wkt-$hex-${now.toRadixString(36)}';
  }
}
