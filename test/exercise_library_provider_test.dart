import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/models/exercise_model.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/exercise_library_provider.dart';
import 'package:fitness_app/repositories/exercise_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExerciseRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExerciseRepository(db);

    // Pre-populate with test data.
    await repo.insertAll([
      _makeExercise(id: '0001', name: 'Bench Press'),
      _makeExercise(id: '0002', name: 'Incline Press', equipment: 'dumbbell'),
      _makeExercise(id: '0003', name: 'Squat', bodyPart: 'upper legs'),
      _makeExercise(id: '0004', name: 'Deadlift', bodyPart: 'back'),
      _makeExercise(id: '0005', name: 'Pull Up', bodyPart: 'back', equipment: 'body weight'),
    ]);

    container = ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('ExerciseLibraryProvider', () {
    test('initial load returns all exercises', () async {
      final subscriber = container.listen(
        exerciseLibraryProvider,
        (_, _) {},
      );

      // Wait for the initial microtask + query to complete.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      final exercises = state.exercises;

      expect(exercises.hasValue, isTrue);
      expect(exercises.value!, hasLength(5));

      subscriber.close();
    });

    test('setQuery filters by name', () async {
      final subscriber = container.listen(
        exerciseLibraryProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(exerciseLibraryProvider.notifier);
      await notifier.setQuery('press');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      final exercises = state.exercises.value!;

      expect(exercises, hasLength(2));
      expect(exercises.every((e) => e.name.toLowerCase().contains('press')), isTrue);

      subscriber.close();
    });

    test('toggleBodyPart filters by body part', () async {
      final subscriber = container.listen(
        exerciseLibraryProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(exerciseLibraryProvider.notifier);
      await notifier.toggleBodyPart('chest');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      final exercises = state.exercises.value!;

      expect(exercises, hasLength(2));
      expect(exercises.every((e) => e.bodyPart == 'chest'), isTrue);

      subscriber.close();
    });

    test('toggleEquipment filters by equipment', () async {
      final subscriber = container.listen(
        exerciseLibraryProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(exerciseLibraryProvider.notifier);
      await notifier.toggleEquipment('barbell');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      final exercises = state.exercises.value!;

      expect(exercises, hasLength(3));
      expect(exercises.every((e) => e.equipment == 'barbell'), isTrue);

      subscriber.close();
    });

    test('clearFilters resets to all exercises', () async {
      final subscriber = container.listen(
        exerciseLibraryProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(exerciseLibraryProvider.notifier);
      await notifier.toggleBodyPart('chest');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await notifier.clearFilters();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      final exercises = state.exercises.value!;

      expect(exercises, hasLength(5));

      subscriber.close();
    });

    test('setViewMode updates view mode', () {
      final notifier = container.read(exerciseLibraryProvider.notifier);
      notifier.setViewMode(ExerciseViewMode.list);

      final state = container.read(exerciseLibraryProvider);
      expect(state.filter.viewMode, ExerciseViewMode.list);
    });

    test('filter.isEmpty returns true when no filters active', () {
      const filter = ExerciseFilter();
      expect(filter.isEmpty, isTrue);
    });

    test('filter.isEmpty returns false when query is set', () {
      const filter = ExerciseFilter(query: 'bench');
      expect(filter.isEmpty, isFalse);
    });

    test('filter.isEmpty returns false when bodyParts is set', () {
      const filter = ExerciseFilter(bodyParts: {'chest'});
      expect(filter.isEmpty, isFalse);
    });
  });
}

ExerciseModel _makeExercise({
  required String id,
  required String name,
  String bodyPart = 'chest',
  String equipment = 'barbell',
}) {
  return ExerciseModel(
    id: id,
    name: name,
    category: bodyPart,
    bodyPart: bodyPart,
    equipment: equipment,
    instructions: {'en': '...'},
    instructionSteps: {'en': ['...']},
    muscleGroup: 'chest',
    target: 'pectorals',
    mediaId: 'm$id',
    image: 'i$id',
    gifUrl: 'g$id',
    attribution: '© Gym visual',
    createdAt: '2024-01-01T00:00:00Z',
  );
}
