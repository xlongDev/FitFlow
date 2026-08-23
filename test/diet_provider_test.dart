import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/models/diet_model.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/diet_provider.dart';
import 'package:fitness_app/repositories/diet_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DietRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DietRepository(db);

    container = ProviderContainer(
      overrides: [
        dietRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('DietRepository', () {
    test('addRecord and getRecordsForDate', () async {
      final date = DateTime(2026, 9, 4);
      final record = DietRecordModel(
        id: 'r1',
        date: date.toIso8601String(),
        mealType: MealType.breakfast,
        foodName: 'Oatmeal',
        quantity: 200,
        calories: 300,
        protein: 10,
        carbs: 50,
        fat: 5,
        createdAt: DateTime.now().toIso8601String(),
      );

      await repo.addRecord(record);

      final records = await repo.getRecordsForDate(date);
      expect(records, hasLength(1));
      expect(records.first.foodName, 'Oatmeal');
      expect(records.first.mealType, MealType.breakfast);
    });

    test('removeRecord deletes the record', () async {
      final date = DateTime(2026, 9, 4);
      final record = DietRecordModel(
        id: 'r1',
        date: date.toIso8601String(),
        mealType: MealType.lunch,
        foodName: 'Chicken',
        calories: 200,
        protein: 30,
        fat: 8,
        createdAt: DateTime.now().toIso8601String(),
      );

      await repo.addRecord(record);
      await repo.removeRecord('r1');

      final records = await repo.getRecordsForDate(date);
      expect(records, isEmpty);
    });

    test('getSummaryForDate aggregates nutrition', () async {
      final date = DateTime(2026, 9, 4);
      await repo.addRecord(DietRecordModel(
        id: 'r1',
        date: date.toIso8601String(),
        mealType: MealType.breakfast,
        foodName: 'Oatmeal',
        calories: 300,
        protein: 10,
        carbs: 50,
        fat: 5,
        createdAt: DateTime.now().toIso8601String(),
      ));
      await repo.addRecord(DietRecordModel(
        id: 'r2',
        date: date.toIso8601String(),
        mealType: MealType.lunch,
        foodName: 'Chicken',
        calories: 200,
        protein: 30,
        fat: 8,
        createdAt: DateTime.now().toIso8601String(),
      ));

      final summary = await repo.getSummaryForDate(date);

      expect(summary.totalCalories, 500);
      expect(summary.totalProtein, 40);
      expect(summary.totalCarbs, 50);
      expect(summary.totalFat, 13);
      expect(summary.records, hasLength(2));
    });

    test('createPlan and activePlan', () async {
      final id = await repo.createPlan(
        name: 'Cutting',
        goal: '减脂',
        targetCalories: 1800,
        targetProtein: 180,
        targetCarbs: 150,
        targetFat: 60,
      );

      // No active plan yet.
      var active = await repo.activePlan();
      expect(active, isNull);

      await repo.setActivePlan(id);

      active = await repo.activePlan();
      expect(active, isNotNull);
      expect(active!.name, 'Cutting');
      expect(active.isActive, isTrue);
    });

    test('setActivePlan deactivates others', () async {
      final id1 = await repo.createPlan(name: 'Plan A');
      final id2 = await repo.createPlan(name: 'Plan B');

      await repo.setActivePlan(id1);
      var active = await repo.activePlan();
      expect(active!.id, id1);

      await repo.setActivePlan(id2);
      active = await repo.activePlan();
      expect(active!.id, id2);

      final plans = await repo.allPlans();
      expect(plans.where((p) => p.isActive), hasLength(1));
    });

    test('updatePlan changes fields', () async {
      await repo.createPlan(name: 'Original');
      final plan = (await repo.allPlans()).first;

      await repo.updatePlan(plan.copyWith(name: 'Updated'));

      final plans = await repo.allPlans();
      expect(plans.first.name, 'Updated');
    });

    test('deletePlan removes the plan', () async {
      final id = await repo.createPlan(name: 'To Delete');

      await repo.deletePlan(id);

      final plans = await repo.allPlans();
      expect(plans, isEmpty);
    });
  });

  group('DietProvider', () {
    test('initial state has today as selected date', () {
      final state = container.read(dietProvider);
      final today = DateTime.now();
      expect(state.selectedDate.year, today.year);
      expect(state.selectedDate.month, today.month);
      expect(state.selectedDate.day, today.day);
    });

    test('selectDate updates selected date', () async {
      final notifier = container.read(dietProvider.notifier);
      await notifier.selectDate(DateTime(2026, 9));

      final state = container.read(dietProvider);
      expect(state.selectedDate, DateTime(2026, 9));
    });

    test('addRecord refreshes the summary', () async {
      final subscriber = container.listen(dietProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      await container.read(dietProvider.notifier).addRecord(DietRecordModel(
        id: 'r1',
        date: date.toIso8601String(),
        mealType: MealType.breakfast,
        foodName: 'Test',
        calories: 100,
        protein: 5,
        carbs: 20,
        fat: 2,
        createdAt: DateTime.now().toIso8601String(),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = subscriber.read();
      expect(state.summary.totalCalories, 100);

      subscriber.close();
    });
  });
}
