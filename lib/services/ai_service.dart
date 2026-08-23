import '../models/ai_model.dart';

/// Abstract interface for AI-powered plan generation.
///
/// On production, the real implementation would call an AI API (e.g.
/// OpenAI, Claude) via Dio. When no API key is available, the
/// [MockAIService] is used — it generates deterministic plans based on
/// the user's input using rule-based logic.
///
/// The UI / Repository layer depends on this abstract interface, never on
/// the concrete implementation. This keeps AI API code out of the business
/// logic and makes the AI feature testable without an API key.
abstract interface class AIService {
  /// Generates a personalized training plan based on [request].
  ///
  /// Returns an [AITrainingPlanResult] with days and exercises tailored to
  /// the user's profile, goal, and available equipment.
  Future<AITrainingPlanResult> generateTrainingPlan(
    AITrainingPlanRequest request,
  );

  /// Generates a personalized diet plan based on [request].
  ///
  /// Returns an [AIDietPlanResult] with daily nutrition targets and meal
  /// suggestions tailored to the user's profile and goal.
  Future<AIDietPlanResult> generateDietPlan(
    AIDietPlanRequest request,
  );
}
