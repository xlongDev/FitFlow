import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/training_plan_table.dart';
import '../models/training_plan_model.dart';
import '../utils/app_logger.dart';

/// Data-access layer for training plans.
///
/// Translates between [TrainingPlanModel] (the immutable domain model with
/// nested days / exercises) and the three drift tables ([TrainingPlans],
/// [TrainingDays], [TrainingExercises]). UI code never touches the database
/// directly — it goes through this repository via a Riverpod provider.
///
/// Responsibilities:
///   * CRUD for plans, days, and exercises.
///   * Load the full plan tree (plan → days → exercises) in one call.
///   * Reorder days and exercises.
///   * Duplicate a plan (deep copy with new ids).
class TrainingPlanRepository {
  TrainingPlanRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Plan CRUD
  // ---------------------------------------------------------------------------

  /// Returns all training plans, ordered by name.
  Future<List<TrainingPlanModel>> allPlans() async {
    final rows = await (_db.select(_db.trainingPlans)
          ..orderBy([(TrainingPlans t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_rowToPlanSummary).toList();
  }

  /// Loads a single plan with all its days and exercises.
  ///
  /// Returns `null` if the plan doesn't exist.
  Future<TrainingPlanModel?> getPlan(String planId) async {
    final planRow = await (_db.select(_db.trainingPlans)
          ..where((TrainingPlans t) => t.id.equals(planId)))
        .getSingleOrNull();
    if (planRow == null) return null;

    final dayRows = await (_db.select(_db.trainingDays)
          ..where((TrainingDays t) => t.planId.equals(planId))
          ..orderBy([(TrainingDays t) => OrderingTerm.asc(t.dayIndex)]))
        .get();

    final days = <TrainingDayModel>[];
    for (final dayRow in dayRows) {
      final exerciseRows = await (_db.select(_db.trainingExercises)
            ..where((TrainingExercises t) => t.dayId.equals(dayRow.id))
            ..orderBy([(TrainingExercises t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      days.add(_rowToDay(dayRow, exerciseRows.map(_rowToExercise).toList()));
    }

    return _rowToPlan(planRow, days);
  }

  /// Creates a new plan. Returns the created plan's id.
  Future<String> createPlan({
    required String name,
    String description = '',
    String goal = '',
    int daysPerWeek = 3,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = _uuid();

    await _db.into(_db.trainingPlans).insert(
          TrainingPlansCompanion.insert(
            id: id,
            name: name,
            description: Value(description),
            goal: Value(goal),
            daysPerWeek: Value(daysPerWeek),
            createdAt: now,
            updatedAt: now,
          ),
        );
    AppLogger.i('TrainingPlan: created "$name" ($id)');
    return id;
  }

  /// Updates a plan's metadata (name, description, goal, daysPerWeek).
  Future<void> updatePlan(TrainingPlanModel plan) async {
    await (_db.update(_db.trainingPlans)
          ..where((TrainingPlans t) => t.id.equals(plan.id)))
        .write(
      TrainingPlansCompanion(
        name: Value(plan.name),
        description: Value(plan.description),
        goal: Value(plan.goal),
        daysPerWeek: Value(plan.daysPerWeek),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  /// Deletes a plan and all its days and exercises.
  Future<void> deletePlan(String planId) async {
    await _db.transaction(() async {
      // Delete exercises for all days in this plan.
      final dayIds = (await (_db.select(_db.trainingDays)
                ..where((TrainingDays t) => t.planId.equals(planId)))
              .get())
          .map((d) => d.id)
          .toList();
      for (final dayId in dayIds) {
        await (_db.delete(_db.trainingExercises)
              ..where((TrainingExercises t) => t.dayId.equals(dayId)))
            .go();
      }
      // Delete days.
      await (_db.delete(_db.trainingDays)
            ..where((TrainingDays t) => t.planId.equals(planId)))
          .go();
      // Delete the plan.
      await (_db.delete(_db.trainingPlans)
            ..where((TrainingPlans t) => t.id.equals(planId)))
          .go();
    });
    AppLogger.i('TrainingPlan: deleted $planId');
  }

  /// Duplicates a plan (deep copy with new ids).
  ///
  /// Returns the new plan's id.
  Future<String> duplicatePlan(String planId) async {
    final original = await getPlan(planId);
    if (original == null) {
      throw StateError('Plan $planId not found');
    }

    final newId = await createPlan(
      name: '${original.name} (Copy)',
      description: original.description,
      goal: original.goal,
      daysPerWeek: original.daysPerWeek,
    );

    for (final day in original.days) {
      final newDayId = await addDay(newId, day.name, day.dayIndex);
      for (final exercise in day.exercises) {
        await addExercise(
          dayId: newDayId,
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: exercise.weight,
          restSeconds: exercise.restSeconds,
          sortOrder: exercise.sortOrder,
          notes: exercise.notes,
        );
      }
    }

    AppLogger.i('TrainingPlan: duplicated "$planId" → "$newId"');
    return newId;
  }

  // ---------------------------------------------------------------------------
  // Day CRUD
  // ---------------------------------------------------------------------------

  /// Adds a day to a plan. Returns the new day's id.
  Future<String> addDay(
    String planId,
    String name,
    int dayIndex,
  ) async {
    final id = _uuid();
    await _db.into(_db.trainingDays).insert(
          TrainingDaysCompanion.insert(
            id: id,
            planId: planId,
            name: name,
            dayIndex: Value(dayIndex),
          ),
        );
    return id;
  }

  /// Renames a day.
  Future<void> updateDayName(String dayId, String name) async {
    await (_db.update(_db.trainingDays)
          ..where((TrainingDays t) => t.id.equals(dayId)))
        .write(TrainingDaysCompanion(name: Value(name)));
  }

  /// Reorders days within a plan.
  Future<void> reorderDays(String planId, List<String> dayIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < dayIds.length; i++) {
        await (_db.update(_db.trainingDays)
              ..where((TrainingDays t) => t.id.equals(dayIds[i])))
            .write(TrainingDaysCompanion(dayIndex: Value(i)));
      }
    });
  }

  /// Deletes a day and all its exercises.
  Future<void> deleteDay(String dayId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.trainingExercises)
            ..where((TrainingExercises t) => t.dayId.equals(dayId)))
          .go();
      await (_db.delete(_db.trainingDays)
            ..where((TrainingDays t) => t.id.equals(dayId)))
          .go();
    });
  }

  // ---------------------------------------------------------------------------
  // Exercise CRUD
  // ---------------------------------------------------------------------------

  /// Adds an exercise to a day. Returns the new exercise's id.
  Future<String> addExercise({
    required String dayId,
    required String exerciseId,
    required String exerciseName,
    int sets = 3,
    String reps = '8',
    double weight = 0,
    int restSeconds = 90,
    int sortOrder = 0,
    String notes = '',
  }) async {
    final id = _uuid();
    await _db.into(_db.trainingExercises).insert(
          TrainingExercisesCompanion.insert(
            id: id,
            dayId: dayId,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            sets: Value(sets),
            reps: Value(reps),
            weight: Value(weight),
            restSeconds: Value(restSeconds),
            sortOrder: Value(sortOrder),
            notes: Value(notes),
          ),
        );
    return id;
  }

  /// Updates an exercise's configuration.
  Future<void> updateExercise(TrainingExerciseModel exercise) async {
    await (_db.update(_db.trainingExercises)
          ..where((TrainingExercises t) => t.id.equals(exercise.id)))
        .write(
      TrainingExercisesCompanion(
        sets: Value(exercise.sets),
        reps: Value(exercise.reps),
        weight: Value(exercise.weight),
        restSeconds: Value(exercise.restSeconds),
        notes: Value(exercise.notes),
      ),
    );
  }

  /// Reorders exercises within a day.
  Future<void> reorderExercises(String dayId, List<String> exerciseIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < exerciseIds.length; i++) {
        await (_db.update(_db.trainingExercises)
              ..where((TrainingExercises t) => t.id.equals(exerciseIds[i])))
            .write(TrainingExercisesCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Removes an exercise from a day.
  Future<void> removeExercise(String exerciseId) async {
    await (_db.delete(_db.trainingExercises)
          ..where((TrainingExercises t) => t.id.equals(exerciseId)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Row → Model conversion
  // ---------------------------------------------------------------------------

  TrainingPlanModel _rowToPlanSummary(TrainingPlanRow r) {
    return TrainingPlanModel(
      id: r.id,
      name: r.name,
      description: r.description,
      goal: r.goal,
      daysPerWeek: r.daysPerWeek,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  TrainingPlanModel _rowToPlan(TrainingPlanRow r, List<TrainingDayModel> days) {
    return TrainingPlanModel(
      id: r.id,
      name: r.name,
      description: r.description,
      goal: r.goal,
      daysPerWeek: r.daysPerWeek,
      days: days,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  TrainingDayModel _rowToDay(TrainingDayRow r, List<TrainingExerciseModel> exercises) {
    return TrainingDayModel(
      id: r.id,
      planId: r.planId,
      name: r.name,
      dayIndex: r.dayIndex,
      exercises: exercises,
    );
  }

  TrainingExerciseModel _rowToExercise(TrainingExerciseRow r) {
    return TrainingExerciseModel(
      id: r.id,
      dayId: r.dayId,
      exerciseId: r.exerciseId,
      exerciseName: r.exerciseName,
      sets: r.sets,
      reps: r.reps,
      weight: r.weight,
      restSeconds: r.restSeconds,
      sortOrder: r.sortOrder,
      notes: r.notes,
    );
  }

  /// Generates a unique id string.
  ///
  /// Uses a timestamp + random suffix — sufficient for local-only ids.
  /// No external dependency needed.
  String _uuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = now ^ (now << 32);
    final hex = random.toRadixString(16).padLeft(16, '0');
    return 'plan-$hex-${now.toRadixString(36)}';
  }
}
