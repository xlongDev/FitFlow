import 'package:drift/drift.dart';

/// The `diet_records` table — individual food intake records.
///
/// Each row is one food item logged at a specific meal on a specific date.
/// Multiple records per meal type are allowed.
@DataClassName('DietRecordRow')
class DietRecords extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// The date this record belongs to (ISO 8601, day only).
  TextColumn get date => text()();

  /// Which meal: 'breakfast', 'lunch', 'dinner', 'snack'.
  TextColumn get mealType => text()();

  /// Food name.
  TextColumn get foodName => text()();

  /// Quantity in grams or ml.
  RealColumn get quantity => real().withDefault(const Constant(100))();

  /// Unit (e.g. 'g', 'ml', 'piece').
  TextColumn get unit => text().withDefault(const Constant('g'))();

  /// Calories in kcal.
  RealColumn get calories => real().withDefault(const Constant(0))();

  /// Protein in grams.
  RealColumn get protein => real().withDefault(const Constant(0))();

  /// Carbohydrates in grams.
  RealColumn get carbs => real().withDefault(const Constant(0))();

  /// Fat in grams.
  RealColumn get fat => real().withDefault(const Constant(0))();

  /// Optional user notes.
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// When the record was created (ISO 8601).
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The `diet_plans` table — the user's daily nutrition target plans.
///
/// Only one plan should be active at a time (enforced at the repository
/// level, not by a DB constraint, so the user can switch freely).
@DataClassName('DietPlanRow')
class DietPlans extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Plan name.
  TextColumn get name => text()();

  /// Goal (e.g. '增肌', '减脂').
  TextColumn get goal => text().withDefault(const Constant(''))();

  /// Target daily calories.
  RealColumn get targetCalories =>
      real().withDefault(const Constant(2000))();

  /// Target daily protein.
  RealColumn get targetProtein =>
      real().withDefault(const Constant(150))();

  /// Target daily carbs.
  RealColumn get targetCarbs =>
      real().withDefault(const Constant(250))();

  /// Target daily fat.
  RealColumn get targetFat =>
      real().withDefault(const Constant(65))();

  /// Whether this is the active plan.
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();

  /// ISO 8601 creation timestamp.
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
