import 'package:freezed_annotation/freezed_annotation.dart';

part 'diet_model.freezed.dart';
part 'diet_model.g.dart';

/// The meal type — which meal of the day this record represents.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

/// A single food intake record (one meal entry).
///
/// Each record captures the food name, quantity, and macronutrient breakdown
/// (calories, protein, carbs, fat). Multiple records per meal type are
/// allowed — e.g. two items for breakfast.
@freezed
abstract class DietRecordModel with _$DietRecordModel {
  const factory DietRecordModel({
    /// UUID primary key.
    required String id,

    /// The date this record belongs to (day only, ISO 8601).
    required String date,

    /// Which meal this record belongs to.
    required MealType mealType,

    /// Food name (e.g. "Chicken Breast", "Oatmeal").
    required String foodName,

    /// Quantity in grams or ml.
    @Default(100) double quantity,

    /// Unit (e.g. "g", "ml", "piece").
    @Default('g') String unit,

    /// Calories in kcal.
    @Default(0) double calories,

    /// Protein in grams.
    @Default(0) double protein,

    /// Carbohydrates in grams.
    @Default(0) double carbs,

    /// Fat in grams.
    @Default(0) double fat,

    /// Optional user notes.
    @Default('') String notes,

    /// When the record was created (ISO 8601).
    required String createdAt,
  }) = _DietRecordModel;

  factory DietRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DietRecordModelFromJson(json);
}

/// A diet plan — the user's daily nutrition targets.
///
/// Stores the target calories and macro split. The diet page compares
/// actual intake against these targets to show progress.
@freezed
abstract class DietPlanModel with _$DietPlanModel {
  const factory DietPlanModel({
    /// UUID primary key.
    required String id,

    /// Plan name (e.g. "Cutting", "Bulking", "Maintenance").
    required String name,

    /// The user's goal (e.g. "增肌", "减脂", "维持").
    @Default('') String goal,

    /// Target daily calories in kcal.
    @Default(2000) double targetCalories,

    /// Target daily protein in grams.
    @Default(150) double targetProtein,

    /// Target daily carbs in grams.
    @Default(250) double targetCarbs,

    /// Target daily fat in grams.
    @Default(65) double targetFat,

    /// Whether this is the active plan.
    @Default(false) bool isActive,

    /// ISO 8601 creation timestamp.
    required String createdAt,
  }) = _DietPlanModel;

  factory DietPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DietPlanModelFromJson(json);
}

/// Aggregated nutrition summary for a day.
///
/// Computed by summing all [DietRecordModel]s for a given date. Used by the
/// diet page to show progress bars against the active plan's targets.
class NutritionSummary {
  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.records,
  });

  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<DietRecordModel> records;

  /// Groups records by meal type and returns a map.
  Map<MealType, List<DietRecordModel>> get byMealType {
    final map = <MealType, List<DietRecordModel>>{};
    for (final r in records) {
      map.putIfAbsent(r.mealType, () => []).add(r);
    }
    return map;
  }
}
