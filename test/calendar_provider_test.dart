import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/providers/calendar_provider.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/repositories/calendar_repository.dart';
import 'package:fitness_app/repositories/training_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TrainingPlanRepository trainingPlanRepo;
  late CalendarRepository calendarRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    trainingPlanRepo = TrainingPlanRepository(db);
    calendarRepo = CalendarRepository(db, trainingPlanRepo);

    container = ProviderContainer(
      overrides: [
        trainingPlanRepositoryProvider.overrideWithValue(trainingPlanRepo),
        calendarRepositoryProvider.overrideWithValue(calendarRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('CalendarRepository', () {
    test('scheduleWorkout and getForDate', () async {
      final planId = await trainingPlanRepo.createPlan(name: 'PPL');
      final dayId = await trainingPlanRepo.addDay(planId, 'Push', 0);

      final date = DateTime(2026, 9);
      await calendarRepo.scheduleWorkout(
        date: date,
        planId: planId,
        planDayId: dayId,
      );

      final workout = await calendarRepo.getForDate(date);

      expect(workout, isNotNull);
      expect(workout!.planDayId, dayId);
      expect(workout.dayName, 'Push');
      expect(workout.planName, 'PPL');
      expect(workout.isCompleted, isFalse);
      expect(workout.isRestDay, isFalse);
    });

    test('markRestDay sets isRestDay and clears planDayId', () async {
      final date = DateTime(2026, 9, 2);
      await calendarRepo.markRestDay(date);

      final workout = await calendarRepo.getForDate(date);

      expect(workout, isNotNull);
      expect(workout!.isRestDay, isTrue);
      expect(workout.planDayId, isNull);
    });

    test('toggleCompleted flips the completed state', () async {
      final planId = await trainingPlanRepo.createPlan(name: 'PPL');
      final dayId = await trainingPlanRepo.addDay(planId, 'Push', 0);
      final date = DateTime(2026, 9, 3);

      await calendarRepo.scheduleWorkout(
        date: date,
        planId: planId,
        planDayId: dayId,
      );

      await calendarRepo.toggleCompleted(date);
      expect((await calendarRepo.getForDate(date))!.isCompleted, isTrue);

      await calendarRepo.toggleCompleted(date);
      expect((await calendarRepo.getForDate(date))!.isCompleted, isFalse);
    });

    test('clearDate removes the schedule', () async {
      final date = DateTime(2026, 9, 4);
      await calendarRepo.markRestDay(date);

      await calendarRepo.clearDate(date);

      final workout = await calendarRepo.getForDate(date);
      expect(workout, isNull);
    });

    test('getMonth returns workouts in the month', () async {
      final planId = await trainingPlanRepo.createPlan(name: 'PPL');
      final dayId = await trainingPlanRepo.addDay(planId, 'Push', 0);

      await calendarRepo.scheduleWorkout(
        date: DateTime(2026, 9),
        planId: planId,
        planDayId: dayId,
      );
      await calendarRepo.scheduleWorkout(
        date: DateTime(2026, 9, 15),
        planId: planId,
        planDayId: dayId,
      );
      await calendarRepo.scheduleWorkout(
        date: DateTime(2026, 10),
        planId: planId,
        planDayId: dayId,
      );

      final workouts = await calendarRepo.getMonth(DateTime(2026, 9, 15));

      expect(workouts, hasLength(2));
    });

    test('scheduleWorkout replaces existing schedule for the date', () async {
      final planId = await trainingPlanRepo.createPlan(name: 'PPL');
      final dayId1 = await trainingPlanRepo.addDay(planId, 'Push', 0);
      final dayId2 = await trainingPlanRepo.addDay(planId, 'Pull', 1);
      final date = DateTime(2026, 9, 5);

      await calendarRepo.scheduleWorkout(
        date: date,
        planId: planId,
        planDayId: dayId1,
      );
      await calendarRepo.scheduleWorkout(
        date: date,
        planId: planId,
        planDayId: dayId2,
      );

      final workout = await calendarRepo.getForDate(date);
      expect(workout!.planDayId, dayId2);
      expect(workout.dayName, 'Pull');
    });
  });

  group('CalendarProvider', () {
    test('initial state has today as focused and selected', () {
      final state = container.read(calendarProvider);
      final today = DateTime.now();
      expect(state.focusedDate.year, today.year);
      expect(state.focusedDate.month, today.month);
      expect(state.focusedDate.day, today.day);
    });

    test('selectDate updates selectedDate', () {
      final notifier = container.read(calendarProvider.notifier);
      notifier.selectDate(DateTime(2026, 9, 15));

      final state = container.read(calendarProvider);
      expect(state.selectedDate, DateTime(2026, 9, 15));
    });

    test('setViewMode switches between month and week', () async {
      final notifier = container.read(calendarProvider.notifier);
      expect(container.read(calendarProvider).viewMode, CalendarViewMode.month);

      await notifier.setViewMode(CalendarViewMode.week);
      expect(container.read(calendarProvider).viewMode, CalendarViewMode.week);

      await notifier.setViewMode(CalendarViewMode.month);
      expect(container.read(calendarProvider).viewMode, CalendarViewMode.month);
    });

    test('markRestDay schedules a rest day on selected date', () async {
      final notifier = container.read(calendarProvider.notifier);
      notifier.selectDate(DateTime(2026, 9, 10));

      await notifier.markRestDay();

      final workout = await calendarRepo.getForDate(DateTime(2026, 9, 10));
      expect(workout, isNotNull);
      expect(workout!.isRestDay, isTrue);
    });
  });
}
