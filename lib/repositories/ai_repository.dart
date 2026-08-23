import '../models/ai_model.dart';
import '../services/ai_service.dart';
import '../utils/app_logger.dart';

/// Data-access layer for AI-powered plan generation.
///
/// Wraps [AIService] and provides higher-level methods that convert AI
/// results into database-ready models. The UI layer goes through this
/// repository via a Riverpod provider — never touches [AIService] directly.
class AIRepository {
  AIRepository(this._service);

  final AIService _service;

  /// Generates a training plan via AI.
  Future<AITrainingPlanResult> generateTrainingPlan(
    AITrainingPlanRequest request,
  ) async {
    try {
      AppLogger.i('AIRepository: generating training plan');
      final result = await _service.generateTrainingPlan(request);
      AppLogger.i('AIRepository: training plan generated — '
          '${result.days.length} days');
      return result;
    } catch (e, st) {
      AppLogger.e('AIRepository: training plan generation failed', e, st);
      rethrow;
    }
  }

  /// Generates a diet plan via AI.
  Future<AIDietPlanResult> generateDietPlan(
    AIDietPlanRequest request,
  ) async {
    try {
      AppLogger.i('AIRepository: generating diet plan');
      final result = await _service.generateDietPlan(request);
      AppLogger.i('AIRepository: diet plan generated — '
          '${result.targetCalories.toStringAsFixed(0)} kcal');
      return result;
    } catch (e, st) {
      AppLogger.e('AIRepository: diet plan generation failed', e, st);
      rethrow;
    }
  }
}
