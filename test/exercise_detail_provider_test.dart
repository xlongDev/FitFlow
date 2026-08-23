import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/models/exercise_model.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/exercise_detail_provider.dart';
import 'package:fitness_app/repositories/exercise_repository.dart';
import 'package:fitness_app/repositories/recently_viewed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExerciseRepository exerciseRepo;
  late RecentlyViewedRepository recentlyViewedRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    exerciseRepo = ExerciseRepository(db);
    recentlyViewedRepo = RecentlyViewedRepository(db, exerciseRepo);

    // Pre-populate with test data.
    await exerciseRepo.insertAll([
      _makeExercise(id: '0001', name: 'Bench Press'),
      _makeExercise(id: '0002', name: 'Squat'),
    ]);

    container = ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
        recentlyViewedRepositoryProvider.overrideWithValue(recentlyViewedRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('exerciseDetailProvider', () {
    test('loads an existing exercise', () async {
      final exercise = await container.read(exerciseDetailProvider('0001').future);

      expect(exercise, isNotNull);
      expect(exercise!.id, '0001');
      expect(exercise.name, 'Bench Press');
    });

    test('returns null for non-existent id', () async {
      final exercise = await container.read(exerciseDetailProvider('9999').future);

      expect(exercise, isNull);
    });

    test('records view on successful load', () async {
      await container.read(exerciseDetailProvider('0001').future);

      // Give the fire-and-forget recordView a moment to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final recent = await recentlyViewedRepo.recent();
      expect(recent, hasLength(1));
      expect(recent.first.id, '0001');
    });

    test('does not record view for non-existent exercise', () async {
      await container.read(exerciseDetailProvider('9999').future);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final recent = await recentlyViewedRepo.recent();
      expect(recent, isEmpty);
    });
  });

  group('RecentlyViewedRepository', () {
    test('recent returns deduplicated list, newest first', () async {
      await recentlyViewedRepo.recordView('0001');
      await Future<void>.delayed(const Duration(seconds: 1));
      await recentlyViewedRepo.recordView('0002');
      await Future<void>.delayed(const Duration(seconds: 1));
      await recentlyViewedRepo.recordView('0001'); // view 0001 again

      final recent = await recentlyViewedRepo.recent();

      // Deduplicated: 2 entries, not 3.
      expect(recent, hasLength(2));
      // Newest first: 0001 was viewed last.
      expect(recent.first.id, '0001');
      expect(recent.last.id, '0002');
    });

    test('clear removes all history', () async {
      await recentlyViewedRepo.recordView('0001');
      await recentlyViewedRepo.recordView('0002');

      await recentlyViewedRepo.clear();

      final recent = await recentlyViewedRepo.recent();
      expect(recent, isEmpty);
    });

    test('respects limit parameter', () async {
      // Only 2 exercises exist (0001, 0002). View them with distinct timestamps.
      await recentlyViewedRepo.recordView('0001');
      await Future<void>.delayed(const Duration(seconds: 1));
      await recentlyViewedRepo.recordView('0002');

      final recent = await recentlyViewedRepo.recent(limit: 1);
      expect(recent, hasLength(1));
      // 0002 was viewed last, so it should be first.
      expect(recent.first.id, '0002');
    });
  });
}

ExerciseModel _makeExercise({
  required String id,
  required String name,
}) {
  return ExerciseModel(
    id: id,
    name: name,
    category: 'chest',
    bodyPart: 'chest',
    equipment: 'barbell',
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
