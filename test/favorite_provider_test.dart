import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/models/exercise_model.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/providers/favorite_provider.dart';
import 'package:fitness_app/repositories/exercise_repository.dart';
import 'package:fitness_app/repositories/favorite_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExerciseRepository exerciseRepo;
  late FavoriteRepository favoriteRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    exerciseRepo = ExerciseRepository(db);
    favoriteRepo = FavoriteRepository(db, exerciseRepo);

    // Pre-populate with test data.
    await exerciseRepo.insertAll([
      _makeExercise(id: '0001', name: 'Bench Press'),
      _makeExercise(id: '0002', name: 'Squat'),
      _makeExercise(id: '0003', name: 'Deadlift'),
    ]);

    container = ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
        favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('FavoriteRepository', () {
    test('add and isFavorite', () async {
      expect(await favoriteRepo.isFavorite('0001'), isFalse);

      await favoriteRepo.add('0001');

      expect(await favoriteRepo.isFavorite('0001'), isTrue);
    });

    test('add is idempotent', () async {
      await favoriteRepo.add('0001');
      await favoriteRepo.add('0001'); // should not throw

      expect(await favoriteRepo.isFavorite('0001'), isTrue);
    });

    test('remove deletes favorite', () async {
      await favoriteRepo.add('0001');
      expect(await favoriteRepo.isFavorite('0001'), isTrue);

      await favoriteRepo.remove('0001');
      expect(await favoriteRepo.isFavorite('0001'), isFalse);
    });

    test('toggle adds then removes', () async {
      final first = await favoriteRepo.toggle('0001');
      expect(first, isTrue);
      expect(await favoriteRepo.isFavorite('0001'), isTrue);

      final second = await favoriteRepo.toggle('0001');
      expect(second, isFalse);
      expect(await favoriteRepo.isFavorite('0001'), isFalse);
    });

    test('all returns favorited exercises newest-first', () async {
      await favoriteRepo.add('0001');
      await Future<void>.delayed(const Duration(seconds: 1));
      await favoriteRepo.add('0002');

      final all = await favoriteRepo.all();

      expect(all, hasLength(2));
      expect(all.first.id, '0002'); // newest first
      expect(all.last.id, '0001');
    });

    test('favoriteIds returns a Set of ids', () async {
      await favoriteRepo.add('0001');
      await favoriteRepo.add('0003');

      final ids = await favoriteRepo.favoriteIds();

      expect(ids, {'0001', '0003'});
    });

    test('search filters by name', () async {
      await favoriteRepo.add('0001'); // Bench Press
      await favoriteRepo.add('0002'); // Squat

      final results = await favoriteRepo.search('bench');

      expect(results, hasLength(1));
      expect(results.first.name, 'Bench Press');
    });

    test('clear removes all favorites', () async {
      await favoriteRepo.add('0001');
      await favoriteRepo.add('0002');

      await favoriteRepo.clear();

      expect(await favoriteRepo.all(), isEmpty);
    });
  });

  group('FavoriteListProvider', () {
    test('initial load returns empty list when no favorites', () async {
      final subscriber = container.listen(
        favoriteListProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      expect(state, isA<FavoriteListData>());
      expect((state as FavoriteListData).favorites, isEmpty);

      subscriber.close();
    });

    test('toggle updates the list', () async {
      final subscriber = container.listen(
        favoriteListProvider,
        (_, _) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await container.read(favoriteListProvider.notifier).toggle('0001');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read() as FavoriteListData;
      expect(state.favorites, hasLength(1));
      expect(state.favorites.first.id, '0001');

      subscriber.close();
    });

    test('isFavoriteProvider returns correct state', () async {
      await favoriteRepo.add('0002');

      // Read the provider — it should resolve to true.
      // In Riverpod 3.x, AsyncValue doesn't expose .future directly.
      // We poll until the value is available.
      bool? result;
      for (var i = 0; i < 10; i++) {
        final asyncValue = container.read(isFavoriteProvider('0002'));
        result = asyncValue.value;
        if (result != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(result, isTrue);
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
