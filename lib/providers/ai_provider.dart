import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_model.dart';
import '../repositories/ai_repository.dart';
import '../services/ai_service.dart';
import '../services/mock_ai_service.dart';
import '../utils/app_logger.dart';

/// State for AI training plan generation.
sealed class AITrainingPlanState {
  const AITrainingPlanState();
}

class AITrainingPlanIdle extends AITrainingPlanState {
  const AITrainingPlanIdle();
}

class AITrainingPlanGenerating extends AITrainingPlanState {
  const AITrainingPlanGenerating();
}

class AITrainingPlanGenerated extends AITrainingPlanState {
  const AITrainingPlanGenerated(this.result);

  final AITrainingPlanResult result;
}

class AITrainingPlanError extends AITrainingPlanState {
  const AITrainingPlanError(this.message);

  final String message;
}

/// State for AI diet plan generation.
sealed class AIDietPlanState {
  const AIDietPlanState();
}

class AIDietPlanIdle extends AIDietPlanState {
  const AIDietPlanIdle();
}

class AIDietPlanGenerating extends AIDietPlanState {
  const AIDietPlanGenerating();
}

class AIDietPlanGenerated extends AIDietPlanState {
  const AIDietPlanGenerated(this.result);

  final AIDietPlanResult result;
}

class AIDietPlanError extends AIDietPlanState {
  const AIDietPlanError(this.message);

  final String message;
}

/// Notifier for AI training plan generation.
class AITrainingPlanNotifier extends Notifier<AITrainingPlanState> {
  late AIRepository _repo;

  @override
  AITrainingPlanState build() {
    _repo = ref.watch(aiRepositoryProvider);
    return const AITrainingPlanIdle();
  }

  /// Generates a training plan from [request].
  Future<void> generate(AITrainingPlanRequest request) async {
    state = const AITrainingPlanGenerating();

    try {
      final result = await _repo.generateTrainingPlan(request);
      if (!ref.mounted) return;
      state = AITrainingPlanGenerated(result);
    } catch (e) {
      if (!ref.mounted) return;
      AppLogger.e('AITrainingPlan: generation failed', e);
      state = AITrainingPlanError(e.toString());
    }
  }

  /// Resets to idle state.
  void reset() {
    state = const AITrainingPlanIdle();
  }
}

/// Notifier for AI diet plan generation.
class AIDietPlanNotifier extends Notifier<AIDietPlanState> {
  late AIRepository _repo;

  @override
  AIDietPlanState build() {
    _repo = ref.watch(aiRepositoryProvider);
    return const AIDietPlanIdle();
  }

  /// Generates a diet plan from [request].
  Future<void> generate(AIDietPlanRequest request) async {
    state = const AIDietPlanGenerating();

    try {
      final result = await _repo.generateDietPlan(request);
      if (!ref.mounted) return;
      state = AIDietPlanGenerated(result);
    } catch (e) {
      if (!ref.mounted) return;
      AppLogger.e('AIDietPlan: generation failed', e);
      state = AIDietPlanError(e.toString());
    }
  }

  /// Resets to idle state.
  void reset() {
    state = const AIDietPlanIdle();
  }
}

/// Provides the [AIService] implementation.
///
/// Currently uses [MockAIService] because no AI API key is configured.
/// When a real API key is available, uncomment the real implementation.
final aiServiceProvider = Provider<AIService>((ref) {
  // When a real AI API is ready:
  // return RealAIService(apiKey: '...');
  return MockAIService();
});

/// Provides the [AIRepository], backed by [aiServiceProvider].
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AIRepository(service);
});

/// Provider for AI training plan generation.
final aiTrainingPlanProvider =
    NotifierProvider<AITrainingPlanNotifier, AITrainingPlanState>(
  AITrainingPlanNotifier.new,
);

/// Provider for AI diet plan generation.
final aiDietPlanProvider =
    NotifierProvider<AIDietPlanNotifier, AIDietPlanState>(
  AIDietPlanNotifier.new,
);
