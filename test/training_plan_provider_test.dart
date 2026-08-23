import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/training_plan_provider.dart';
import 'package:fitness_app/repositories/training_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TrainingPlanRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TrainingPlanRepository(db);

    container = ProviderContainer(
      overrides: [
        trainingPlanRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('TrainingPlanRepository', () {
    test('createPlan and getPlan', () async {
      final id = await repo.createPlan(name: 'Push Pull Legs');

      final plan = await repo.getPlan(id);

      expect(plan, isNotNull);
      expect(plan!.name, 'Push Pull Legs');
      expect(plan.daysPerWeek, 3);
      expect(plan.days, isEmpty);
    });

    test('allPlans returns all plans sorted by name', () async {
      await repo.createPlan(name: 'Z Plan');
      await repo.createPlan(name: 'A Plan');
      await repo.createPlan(name: 'M Plan');

      final plans = await repo.allPlans();

      expect(plans, hasLength(3));
      expect(plans[0].name, 'A Plan');
      expect(plans[1].name, 'M Plan');
      expect(plans[2].name, 'Z Plan');
    });

    test('updatePlan changes name and description', () async {
      final id = await repo.createPlan(name: 'Original');
      final plan = await repo.getPlan(id);

      await repo.updatePlan(
        plan!.copyWith(name: 'Updated', description: 'New desc'),
      );

      final updated = await repo.getPlan(id);
      expect(updated!.name, 'Updated');
      expect(updated.description, 'New desc');
    });

    test('deletePlan removes plan and its days and exercises', () async {
      final planId = await repo.createPlan(name: 'To Delete');
      final dayId = await repo.addDay(planId, 'Day 1', 0);
      await repo.addExercise(
        dayId: dayId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
      );

      await repo.deletePlan(planId);

      final plan = await repo.getPlan(planId);
      expect(plan, isNull);
    });

    test('addDay and getPlan loads days', () async {
      final planId = await repo.createPlan(name: 'Test Plan');
      await repo.addDay(planId, 'Push', 0);
      await repo.addDay(planId, 'Pull', 1);
      await repo.addDay(planId, 'Legs', 2);

      final plan = await repo.getPlan(planId);

      expect(plan!.days, hasLength(3));
      expect(plan.days[0].name, 'Push');
      expect(plan.days[1].name, 'Pull');
      expect(plan.days[2].name, 'Legs');
    });

    test('addExercise and getPlan loads exercises', () async {
      final planId = await repo.createPlan(name: 'Test Plan');
      final dayId = await repo.addDay(planId, 'Day 1', 0);
      await repo.addExercise(
        dayId: dayId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
        sets: 4,
        reps: '8-12',
        weight: 75.0,
      );

      final plan = await repo.getPlan(planId);

      expect(plan!.days[0].exercises, hasLength(1));
      final ex = plan.days[0].exercises.first;
      expect(ex.exerciseName, 'Bench Press');
      expect(ex.sets, 4);
      expect(ex.reps, '8-12');
      expect(ex.weight, 75.0);
      expect(ex.restSeconds, 90);
    });

    test('updateExercise changes config', () async {
      final planId = await repo.createPlan(name: 'Test Plan');
      final dayId = await repo.addDay(planId, 'Day 1', 0);
      await repo.addExercise(
        dayId: dayId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
      );

      final plan = await repo.getPlan(planId);
      final exercise = plan!.days[0].exercises.first;

      await repo.updateExercise(
        exercise.copyWith(sets: 5, reps: '5', weight: 100.0),
      );

      final updated = await repo.getPlan(planId);
      final updatedEx = updated!.days[0].exercises.first;
      expect(updatedEx.sets, 5);
      expect(updatedEx.reps, '5');
      expect(updatedEx.weight, 100.0);
    });

    test('removeExercise deletes exercise from day', () async {
      final planId = await repo.createPlan(name: 'Test Plan');
      final dayId = await repo.addDay(planId, 'Day 1', 0);
      final exId = await repo.addExercise(
        dayId: dayId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
      );

      await repo.removeExercise(exId);

      final plan = await repo.getPlan(planId);
      expect(plan!.days[0].exercises, isEmpty);
    });

    test('duplicatePlan creates a deep copy with new ids', () async {
      final planId = await repo.createPlan(name: 'Original');
      final dayId = await repo.addDay(planId, 'Day 1', 0);
      await repo.addExercise(
        dayId: dayId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
      );

      final newId = await repo.duplicatePlan(planId);

      expect(newId, isNot(planId));

      final original = await repo.getPlan(planId);
      final copy = await repo.getPlan(newId);

      expect(copy!.name, contains('Copy'));
      expect(copy.days, hasLength(1));
      expect(copy.days[0].exercises, hasLength(1));
      expect(copy.days[0].id, isNot(original!.days[0].id));
      expect(copy.days[0].exercises[0].id, isNot(original.days[0].exercises[0].id));
    });

    test('reorderDays updates dayIndex', () async {
      final planId = await repo.createPlan(name: 'Test Plan');
      final day1 = await repo.addDay(planId, 'Day 1', 0);
      final day2 = await repo.addDay(planId, 'Day 2', 1);
      final day3 = await repo.addDay(planId, 'Day 3', 2);

      // Reorder: Day 3, Day 1, Day 2
      await repo.reorderDays(planId, [day3, day1, day2]);

      final plan = await repo.getPlan(planId);
      expect(plan!.days[0].name, 'Day 3');
      expect(plan.days[1].name, 'Day 1');
      expect(plan.days[2].name, 'Day 2');
    });
  });

  group('TrainingPlanListProvider', () {
    test('initial load returns empty list', () async {
      final subscriber = container.listen(
        trainingPlanListProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      expect(state, isA<TrainingPlanListData>());
      expect((state as TrainingPlanListData).plans, isEmpty);

      subscriber.close();
    });

    test('createPlan adds to the list', () async {
      final subscriber = container.listen(
        trainingPlanListProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await container.read(trainingPlanListProvider.notifier).createPlan(name: 'New Plan');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read() as TrainingPlanListData;
      expect(state.plans, hasLength(1));
      expect(state.plans.first.name, 'New Plan');

      subscriber.close();
    });

    test('deletePlan removes from the list', () async {
      final subscriber = container.listen(
        trainingPlanListProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final id = await container.read(trainingPlanListProvider.notifier).createPlan(name: 'To Delete');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await container.read(trainingPlanListProvider.notifier).deletePlan(id);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read() as TrainingPlanListData;
      expect(state.plans, isEmpty);

      subscriber.close();
    });
  });
}
