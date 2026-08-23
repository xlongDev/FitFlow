import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/workout_provider.dart';
import 'package:fitness_app/repositories/calendar_repository.dart';
import 'package:fitness_app/repositories/training_plan_repository.dart';
import 'package:fitness_app/repositories/workout_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TrainingPlanRepository trainingPlanRepo;
  late CalendarRepository calendarRepo;
  late WorkoutRepository workoutRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    trainingPlanRepo = TrainingPlanRepository(db);
    calendarRepo = CalendarRepository(db, trainingPlanRepo);
    workoutRepo = WorkoutRepository(db, calendarRepo);

    container = ProviderContainer(
      overrides: [
        trainingPlanRepositoryProvider.overrideWithValue(trainingPlanRepo),
        calendarRepositoryProvider.overrideWithValue(calendarRepo),
        workoutRepositoryProvider.overrideWithValue(workoutRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('WorkoutRepository', () {
    test('startSession creates a session', () async {
      final id = await workoutRepo.startSession();

      final session = await workoutRepo.getSession(id);

      expect(session, isNotNull);
      expect(session!.id, id);
      expect(session.isCompleted, isFalse);
      expect(session.sets, isEmpty);
    });

    test('addSet adds a set to the session', () async {
      final sessionId = await workoutRepo.startSession();

      final setId = await workoutRepo.addSet(
        sessionId: sessionId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
        setNumber: 1,
        weight: 60,
        reps: 10,
      );

      final session = await workoutRepo.getSession(sessionId);

      expect(session!.sets, hasLength(1));
      expect(session.sets.first.id, setId);
      expect(session.sets.first.exerciseName, 'Bench Press');
      expect(session.sets.first.weight, 60);
      expect(session.sets.first.reps, 10);
      expect(session.sets.first.isCompleted, isFalse);
    });

    test('toggleSetCompletion flips the completed state', () async {
      final sessionId = await workoutRepo.startSession();
      final setId = await workoutRepo.addSet(
        sessionId: sessionId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
        setNumber: 1,
        weight: 60,
        reps: 10,
      );

      await workoutRepo.toggleSetCompletion(setId);

      var session = await workoutRepo.getSession(sessionId);
      expect(session!.sets.first.isCompleted, isTrue);

      await workoutRepo.toggleSetCompletion(setId);
      session = await workoutRepo.getSession(sessionId);
      expect(session!.sets.first.isCompleted, isFalse);
    });

    test('finishSession marks the session complete and computes volume', () async {
      final sessionId = await workoutRepo.startSession();

      await workoutRepo.addSet(
        sessionId: sessionId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
        setNumber: 1,
        weight: 60,
        reps: 10,
      );
      await workoutRepo.addSet(
        sessionId: sessionId,
        exerciseId: '0001',
        exerciseName: 'Bench Press',
        setNumber: 2,
        weight: 70,
        reps: 8,
      );

      // Mark both sets complete.
      final session = await workoutRepo.getSession(sessionId);
      for (final set in session!.sets) {
        await workoutRepo.toggleSetCompletion(set.id);
      }

      await workoutRepo.finishSession(sessionId);

      final finished = await workoutRepo.getSession(sessionId);
      expect(finished!.isCompleted, isTrue);
      expect(finished.endedAt, isNotNull);
      expect(finished.durationSeconds, isNotNull);
      // Total volume: 60*10 + 70*8 = 600 + 560 = 1160
      expect(finished.totalVolume, 1160);
      expect(finished.setsCompleted, 2);
    });

    test('completedSessions returns only finished sessions', () async {
      final id1 = await workoutRepo.startSession();
      await workoutRepo.startSession(); // abandoned

      await workoutRepo.finishSession(id1);

      final completed = await workoutRepo.completedSessions();

      expect(completed, hasLength(1));
      expect(completed.first.id, id1);
    });

    test('abandonSession deletes the session', () async {
      final sessionId = await workoutRepo.startSession();

      await workoutRepo.abandonSession(sessionId);

      final session = await workoutRepo.getSession(sessionId);
      expect(session, isNull);
    });

    test('finishSession marks calendar entry complete', () async {
      // Create a plan + day + schedule it on today's date.
      final planId = await trainingPlanRepo.createPlan(name: 'PPL');
      final dayId = await trainingPlanRepo.addDay(planId, 'Push', 0);
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      await calendarRepo.scheduleWorkout(
        date: date,
        planId: planId,
        planDayId: dayId,
      );
      final scheduled = await calendarRepo.getForDate(date);
      expect(scheduled, isNotNull);
      expect(scheduled!.isCompleted, isFalse);

      // Start a session linked to the scheduled workout.
      final sessionId = await workoutRepo.startSession(
        scheduledWorkoutId: scheduled.id.toString(),
        planDayId: dayId,
        planId: planId,
        planName: 'PPL',
        dayName: 'Push',
      );

      await workoutRepo.finishSession(sessionId);

      // The calendar entry should now be marked complete.
      final updated = await calendarRepo.getForDate(date);
      expect(updated!.isCompleted, isTrue);
    });
  });

  group('WorkoutSessionProvider', () {
    test('initial state is idle', () {
      final state = container.read(workoutSessionProvider);
      expect(state, isA<WorkoutIdle>());
    });

    test('startSession transitions to active', () async {
      final subscriber = container.listen(workoutSessionProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await container.read(workoutSessionProvider.notifier).startSession();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = subscriber.read();
      expect(state, isA<WorkoutActive>());

      subscriber.close();
    });

    test('finishSession transitions back to idle', () async {
      final subscriber = container.listen(workoutSessionProvider, (_, _) {});

      await container.read(workoutSessionProvider.notifier).startSession();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await container.read(workoutSessionProvider.notifier).finishSession();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = subscriber.read();
      expect(state, isA<WorkoutIdle>());

      subscriber.close();
    });
  });
}
