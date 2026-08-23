import 'package:fitness_app/models/ai_model.dart';
import 'package:fitness_app/providers/ai_provider.dart';
import 'package:fitness_app/repositories/ai_repository.dart';
import 'package:fitness_app/services/mock_ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAIService mockService;
  late AIRepository repo;
  late ProviderContainer container;

  setUp(() {
    mockService = MockAIService();
    repo = AIRepository(mockService);

    container = ProviderContainer(
      overrides: [
        aiServiceProvider.overrideWithValue(mockService),
        aiRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MockAIService', () {
    test('generateTrainingPlan returns a plan with days', () async {
      const request = AITrainingPlanRequest(
        gender: 'male',
        height: 175,
        weight: 75,
      );

      final result = await mockService.generateTrainingPlan(request);

      expect(result.planName, isNotEmpty);
      expect(result.days, isNotEmpty);
      expect(result.daysPerWeek, 3);
      expect(result.goal, '增肌');

      // Each day should have exercises.
      for (final day in result.days) {
        expect(day.exercises, isNotEmpty);
      }
    });

    test('generateDietPlan returns a plan with targets and meals', () async {
      const request = AIDietPlanRequest(
        gender: 'male',
        height: 175,
        weight: 75,
      );

      final result = await mockService.generateDietPlan(request);

      expect(result.planName, isNotEmpty);
      expect(result.targetCalories, greaterThan(0));
      expect(result.targetProtein, greaterThan(0));
      expect(result.targetCarbs, greaterThan(0));
      expect(result.targetFat, greaterThan(0));
      expect(result.meals, isNotEmpty);
      expect(result.meals.length, 4); // breakfast, lunch, snack, dinner
    });

    test('different goals produce different calorie targets', () async {
      const bulkRequest = AIDietPlanRequest(
        gender: 'male',
        weight: 75,
      );
      const cutRequest = AIDietPlanRequest(
        gender: 'male',
        weight: 75,
        goal: '减脂',
      );

      final bulkResult = await mockService.generateDietPlan(bulkRequest);
      final cutResult = await mockService.generateDietPlan(cutRequest);

      expect(bulkResult.targetCalories, greaterThan(cutResult.targetCalories));
    });
  });

  group('AIRepository', () {
    test('generateTrainingPlan delegates to service', () async {
      const request = AITrainingPlanRequest(gender: 'male');
      final result = await repo.generateTrainingPlan(request);

      expect(result, isA<AITrainingPlanResult>());
      expect(result.days, isNotEmpty);
    });

    test('generateDietPlan delegates to service', () async {
      const request = AIDietPlanRequest(gender: 'male');
      final result = await repo.generateDietPlan(request);

      expect(result, isA<AIDietPlanResult>());
      expect(result.targetCalories, greaterThan(0));
    });
  });

  group('AITrainingPlanProvider', () {
    test('initial state is idle', () {
      final state = container.read(aiTrainingPlanProvider);
      expect(state, isA<AITrainingPlanIdle>());
    });

    test('generate transitions to generated', () async {
      final subscriber = container.listen(aiTrainingPlanProvider, (_, _) {});

      await container.read(aiTrainingPlanProvider.notifier).generate(
            const AITrainingPlanRequest(gender: 'male'),
          );

      final state = subscriber.read();
      expect(state, isA<AITrainingPlanGenerated>());

      subscriber.close();
    });

    test('reset returns to idle', () async {
      await container.read(aiTrainingPlanProvider.notifier).generate(
            const AITrainingPlanRequest(gender: 'male'),
          );

      container.read(aiTrainingPlanProvider.notifier).reset();

      final state = container.read(aiTrainingPlanProvider);
      expect(state, isA<AITrainingPlanIdle>());
    });
  });

  group('AIDietPlanProvider', () {
    test('initial state is idle', () {
      final state = container.read(aiDietPlanProvider);
      expect(state, isA<AIDietPlanIdle>());
    });

    test('generate transitions to generated', () async {
      final subscriber = container.listen(aiDietPlanProvider, (_, _) {});

      await container.read(aiDietPlanProvider.notifier).generate(
            const AIDietPlanRequest(gender: 'male'),
          );

      final state = subscriber.read();
      expect(state, isA<AIDietPlanGenerated>());

      subscriber.close();
    });

    test('reset returns to idle', () async {
      await container.read(aiDietPlanProvider.notifier).generate(
            const AIDietPlanRequest(gender: 'male'),
          );

      container.read(aiDietPlanProvider.notifier).reset();

      final state = container.read(aiDietPlanProvider);
      expect(state, isA<AIDietPlanIdle>());
    });
  });
}
