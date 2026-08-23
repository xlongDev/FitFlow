import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/default_plans_provider.dart';
import 'package:fitness_app/repositories/diet_repository.dart';
import 'package:fitness_app/repositories/training_plan_repository.dart';
import 'package:fitness_app/services/default_diet_plans_service.dart';
import 'package:fitness_app/services/default_plans_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TrainingPlanRepository trainingPlanRepo;
  late DietRepository dietRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    trainingPlanRepo = TrainingPlanRepository(db);
    dietRepo = DietRepository(db);

    container = ProviderContainer(
      overrides: [
        trainingPlanRepositoryProvider.overrideWithValue(trainingPlanRepo),
        dietRepositoryProvider.overrideWithValue(dietRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('DefaultPlansService', () {
    test('provides training plan templates', () {
      expect(DefaultPlansService.all, isNotEmpty);
      expect(DefaultPlansService.all.length, greaterThanOrEqualTo(4));
    });

    test('each template has at least one day', () {
      for (final template in DefaultPlansService.all) {
        expect(template.days, isNotEmpty,
            reason: '${template.name} should have at least one day');
      }
    });

    test('each day has at least one exercise', () {
      for (final template in DefaultPlansService.all) {
        for (final day in template.days) {
          expect(day.exercises, isNotEmpty,
              reason: '${template.name} / ${day.name} should have exercises');
        }
      }
    });
  });

  group('DefaultDietPlansService', () {
    test('provides diet plan templates', () {
      expect(DefaultDietPlansService.all, isNotEmpty);
      expect(DefaultDietPlansService.all.length, greaterThanOrEqualTo(3));
    });

    test('each template has positive targets', () {
      for (final template in DefaultDietPlansService.all) {
        expect(template.targetCalories, greaterThan(0));
        expect(template.targetProtein, greaterThan(0));
        expect(template.targetCarbs, greaterThan(0));
        expect(template.targetFat, greaterThan(0));
      }
    });
  });

  group('defaultPlansImportProvider', () {
    test('creates plans on first call', () async {
      final result = await container.read(defaultPlansImportProvider.future);

      expect(result, isNotNull);
      expect(result!.trainingPlansCreated, greaterThan(0));
      expect(result.dietPlansCreated, greaterThan(0));

      // Verify training plans were created.
      final plans = await trainingPlanRepo.allPlans();
      expect(plans.length, greaterThanOrEqualTo(4));

      // Verify diet plans were created.
      final dietPlans = await dietRepo.allPlans();
      expect(dietPlans.length, greaterThanOrEqualTo(3));

      // Verify one diet plan is active.
      final active = dietPlans.where((p) => p.isActive);
      expect(active.length, 1);
    });

    test('returns null on second call (idempotent)', () async {
      // First call — creates plans.
      await container.read(defaultPlansImportProvider.future);

      // Need a fresh container because FutureProvider caches.
      final container2 = ProviderContainer(
        overrides: [
          trainingPlanRepositoryProvider.overrideWithValue(trainingPlanRepo),
          dietRepositoryProvider.overrideWithValue(dietRepo),
        ],
      );

      // Second call — should detect existing plans and return null.
      final result = await container2.read(defaultPlansImportProvider.future);
      expect(result, isNull);

      container2.dispose();
    });

    test('created training plans have days and exercises', () async {
      await container.read(defaultPlansImportProvider.future);

      final plans = await trainingPlanRepo.allPlans();
      expect(plans, isNotEmpty);

      // Load the first plan's full tree.
      final plan = await trainingPlanRepo.getPlan(plans.first.id);
      expect(plan, isNotNull);
      expect(plan!.days, isNotEmpty);

      // Each day should have exercises.
      for (final day in plan.days) {
        expect(day.exercises, isNotEmpty,
            reason: '${plan.name} / ${day.name} should have exercises');
      }
    });
  });
}
