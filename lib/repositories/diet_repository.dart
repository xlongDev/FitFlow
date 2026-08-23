import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/diet_table.dart';
import '../models/diet_model.dart';
import '../utils/app_logger.dart';

/// Data-access layer for diet records and diet plans.
///
/// Manages food intake records (grouped by date and meal type) and the
/// user's daily nutrition target plans. The UI layer goes through this
/// repository via a Riverpod provider — never touches the database directly.
class DietRepository {
  DietRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Diet records
  // ---------------------------------------------------------------------------

  /// Adds a food intake record.
  Future<void> addRecord(DietRecordModel record) async {
    await _db.into(_db.dietRecords).insert(
          DietRecordsCompanion.insert(
            id: record.id,
            date: record.date,
            mealType: record.mealType.name,
            foodName: record.foodName,
            quantity: Value(record.quantity),
            unit: Value(record.unit),
            calories: Value(record.calories),
            protein: Value(record.protein),
            carbs: Value(record.carbs),
            fat: Value(record.fat),
            notes: Value(record.notes),
            createdAt: record.createdAt,
          ),
        );
    AppLogger.d('Diet: added record ${record.foodName} for ${record.date}');
  }

  /// Removes a record by id.
  Future<void> removeRecord(String id) async {
    await (_db.delete(_db.dietRecords)
          ..where((DietRecords t) => t.id.equals(id)))
        .go();
  }

  /// Returns all records for [date], grouped by meal type.
  Future<List<DietRecordModel>> getRecordsForDate(DateTime date) async {
    final dateStr = _normalizeDate(date).toIso8601String();
    final rows = await (_db.select(_db.dietRecords)
          ..where((DietRecords t) => t.date.equals(dateStr))
          ..orderBy([(DietRecords t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Computes the nutrition summary for [date].
  Future<NutritionSummary> getSummaryForDate(DateTime date) async {
    final records = await getRecordsForDate(date);
    return NutritionSummary(
      totalCalories: records.fold(0.0, (s, r) => s + r.calories),
      totalProtein: records.fold(0.0, (s, r) => s + r.protein),
      totalCarbs: records.fold(0.0, (s, r) => s + r.carbs),
      totalFat: records.fold(0.0, (s, r) => s + r.fat),
      records: records,
    );
  }

  // ---------------------------------------------------------------------------
  // Diet plans
  // ---------------------------------------------------------------------------

  /// Creates a new diet plan. If [isActive] is true, deactivates all other
  /// plans first so only one is active at a time.
  Future<String> createPlan({
    required String name,
    String goal = '',
    double targetCalories = 2000,
    double targetProtein = 150,
    double targetCarbs = 250,
    double targetFat = 65,
    bool isActive = false,
  }) async {
    final id = _uuid();

    if (isActive) {
      await _deactivateAllPlans();
    }

    await _db.into(_db.dietPlans).insert(
          DietPlansCompanion.insert(
            id: id,
            name: name,
            goal: Value(goal),
            targetCalories: Value(targetCalories),
            targetProtein: Value(targetProtein),
            targetCarbs: Value(targetCarbs),
            targetFat: Value(targetFat),
            isActive: Value(isActive),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
    AppLogger.i('Diet: created plan "$name" (active: $isActive)');
    return id;
  }

  /// Returns all diet plans.
  Future<List<DietPlanModel>> allPlans() async {
    final rows = await (_db.select(_db.dietPlans)
          ..orderBy([(DietPlans t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_planRowToModel).toList();
  }

  /// Returns the active diet plan, or `null` if none is active.
  Future<DietPlanModel?> activePlan() async {
    final row = await (_db.select(_db.dietPlans)
          ..where((DietPlans t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _planRowToModel(row);
  }

  /// Sets [planId] as the active plan, deactivating all others.
  Future<void> setActivePlan(String planId) async {
    await _deactivateAllPlans();
    await (_db.update(_db.dietPlans)
          ..where((DietPlans t) => t.id.equals(planId)))
        .write(const DietPlansCompanion(isActive: Value(true)));
    AppLogger.i('Diet: activated plan $planId');
  }

  /// Updates an existing plan's fields.
  Future<void> updatePlan(DietPlanModel plan) async {
    await (_db.update(_db.dietPlans)
          ..where((DietPlans t) => t.id.equals(plan.id)))
        .write(
      DietPlansCompanion(
        name: Value(plan.name),
        goal: Value(plan.goal),
        targetCalories: Value(plan.targetCalories),
        targetProtein: Value(plan.targetProtein),
        targetCarbs: Value(plan.targetCarbs),
        targetFat: Value(plan.targetFat),
      ),
    );
    AppLogger.d('Diet: updated plan ${plan.id}');
  }

  /// Deletes a diet plan.
  Future<void> deletePlan(String planId) async {
    await (_db.delete(_db.dietPlans)
          ..where((DietPlans t) => t.id.equals(planId)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _deactivateAllPlans() async {
    await (_db.update(_db.dietPlans)
          ..where((DietPlans t) => t.isActive.equals(true)))
        .write(const DietPlansCompanion(isActive: Value(false)));
  }

  DietRecordModel _rowToModel(DietRecordRow r) {
    return DietRecordModel(
      id: r.id,
      date: r.date,
      mealType: MealType.values.byName(r.mealType),
      foodName: r.foodName,
      quantity: r.quantity,
      unit: r.unit,
      calories: r.calories,
      protein: r.protein,
      carbs: r.carbs,
      fat: r.fat,
      notes: r.notes,
      createdAt: r.createdAt,
    );
  }

  DietPlanModel _planRowToModel(DietPlanRow r) {
    return DietPlanModel(
      id: r.id,
      name: r.name,
      goal: r.goal,
      targetCalories: r.targetCalories,
      targetProtein: r.targetProtein,
      targetCarbs: r.targetCarbs,
      targetFat: r.targetFat,
      isActive: r.isActive,
      createdAt: r.createdAt,
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _uuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final hex = now.toRadixString(16).padLeft(16, '0');
    return 'diet-$hex-${now.toRadixString(36)}';
  }
}
