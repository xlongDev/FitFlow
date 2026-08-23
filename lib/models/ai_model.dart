import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

/// User input for AI training plan generation.
///
/// Captures the user's profile and preferences that the AI uses to generate
/// a personalized training plan.
@freezed
abstract class AITrainingPlanRequest with _$AITrainingPlanRequest {
  const factory AITrainingPlanRequest({
    /// 'male' or 'female'.
    required String gender,

    /// User's age in years.
    @Default(25) int age,

    /// User's height in cm.
    @Default(170) int height,

    /// User's weight in kg.
    @Default(70) double weight,

    /// Training experience: 'beginner', 'intermediate', 'advanced'.
    @Default('beginner') String experience,

    /// Goal: '增肌', '减脂', '塑形', '力量提升'.
    @Default('增肌') String goal,

    /// Days per week available for training.
    @Default(3) int daysPerWeek,

    /// Preferred session duration in minutes.
    @Default(60) int sessionDuration,

    /// Available equipment (e.g. 'full gym', 'dumbbells only', 'body weight').
    @Default('full gym') String equipment,
  }) = _AITrainingPlanRequest;

  factory AITrainingPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$AITrainingPlanRequestFromJson(json);
}

/// AI-generated training plan result.
///
/// Contains the plan metadata + days + exercises, ready to be saved to the
/// database via [TrainingPlanRepository].
@freezed
abstract class AITrainingPlanResult with _$AITrainingPlanResult {
  const factory AITrainingPlanResult({
    required String planName,
    required String description,
    required String goal,
    required int daysPerWeek,
    required List<AITrainingDay> days,
  }) = _AITrainingPlanResult;

  factory AITrainingPlanResult.fromJson(Map<String, dynamic> json) =>
      _$AITrainingPlanResultFromJson(json);
}

/// A day in an AI-generated training plan.
@freezed
abstract class AITrainingDay with _$AITrainingDay {
  const factory AITrainingDay({
    required String name,
    required List<AITrainingExercise> exercises,
  }) = _AITrainingDay;

  factory AITrainingDay.fromJson(Map<String, dynamic> json) =>
      _$AITrainingDayFromJson(json);
}

/// An exercise in an AI-generated training day.
@freezed
abstract class AITrainingExercise with _$AITrainingExercise {
  const factory AITrainingExercise({
    required String exerciseId,
    required String exerciseName,
    @Default(3) int sets,
    @Default('8-12') String reps,
    @Default(0) double weight,
    @Default(90) int restSeconds,
    @Default('') String notes,
  }) = _AITrainingExercise;

  factory AITrainingExercise.fromJson(Map<String, dynamic> json) =>
      _$AITrainingExerciseFromJson(json);
}

/// User input for AI diet plan generation.
@freezed
abstract class AIDietPlanRequest with _$AIDietPlanRequest {
  const factory AIDietPlanRequest({
    required String gender,
    @Default(25) int age,
    @Default(170) int height,
    @Default(70) double weight,
    @Default('增肌') String goal,
    @Default('moderate') String activityLevel,
    @Default(3) int trainingDaysPerWeek,
    @Default('') String dietaryPreference,
  }) = _AIDietPlanRequest;

  factory AIDietPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$AIDietPlanRequestFromJson(json);
}

/// AI-generated diet plan result.
@freezed
abstract class AIDietPlanResult with _$AIDietPlanResult {
  const factory AIDietPlanResult({
    required String planName,
    required String goal,
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    required List<AIMealSuggestion> meals,
  }) = _AIDietPlanResult;

  factory AIDietPlanResult.fromJson(Map<String, dynamic> json) =>
      _$AIDietPlanResultFromJson(json);
}

/// A meal suggestion in an AI-generated diet plan.
@freezed
abstract class AIMealSuggestion with _$AIMealSuggestion {
  const factory AIMealSuggestion({
    required String mealType,
    required String foodName,
    @Default(0) double calories,
    @Default(0) double protein,
    @Default(0) double carbs,
    @Default(0) double fat,
  }) = _AIMealSuggestion;

  factory AIMealSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AIMealSuggestionFromJson(json);
}
