import 'dart:convert';

import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/database/exercise_parser.dart';
import 'package:fitness_app/models/exercise_model.dart';
import 'package:fitness_app/repositories/exercise_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // ExerciseParser
  // ---------------------------------------------------------------------------

  group('ExerciseParser.parseJsonString', () {
    test('parses a well-formed record', () {
      const records = [
        {
          'id': '0001',
          'name': 'Bench Press',
          'category': 'chest',
          'body_part': 'chest',
          'equipment': 'barbell',
          'instructions': {'en': 'Lie on bench, press up.', 'zh': '躺在卧推凳上，向上推。'},
          'instruction_steps': {
            'en': ['Lie on bench', 'Press up'],
            'zh': ['躺在卧推凳上', '向上推'],
          },
          'muscle_group': 'chest',
          'secondary_muscles': ['triceps', 'shoulders'],
          'target': 'pectorals',
          'media_id': 'abc123',
          'image': 'images/0001-abc123.jpg',
          'gif_url': 'videos/0001-abc123.gif',
          'attribution': '© Gym visual — gymvisual.com',
          'created_at': '2024-01-01T00:00:00Z',
        },
      ];

      final result = ExerciseParser.parseJsonString(jsonEncode(records));

      expect(result.total, 1);
      expect(result.success, 1);
      expect(result.failed, 0);
      expect(result.duplicated, 0);
      expect(result.exercises, hasLength(1));

      final exercise = result.exercises.first;
      expect(exercise.id, '0001');
      expect(exercise.name, 'Bench Press');
      expect(exercise.bodyPart, 'chest');
      expect(exercise.equipment, 'barbell');
      expect(exercise.instructions['en'], 'Lie on bench, press up.');
      expect(exercise.instructions['zh'], '躺在卧推凳上，向上推。');
      expect(exercise.instructionSteps['en'], ['Lie on bench', 'Press up']);
      expect(exercise.secondaryMuscles, ['triceps', 'shoulders']);
      expect(exercise.attribution, '© Gym visual — gymvisual.com');
    });

    test('skips records with missing required fields', () {
      const records = [
        {
          'id': '0001',
          'name': 'Bench Press',
          'category': 'chest',
          'body_part': 'chest',
          'equipment': 'barbell',
          'instructions': {'en': '...'},
          'instruction_steps': {'en': ['...']},
          'muscle_group': 'chest',
          'target': 'pectorals',
          'media_id': 'abc123',
          'image': 'images/0001-abc123.jpg',
          'gif_url': 'videos/0001-abc123.gif',
          'attribution': '© Gym visual',
          'created_at': '2024-01-01T00:00:00Z',
        },
        {
          // Missing id — should be skipped.
          'name': 'Bad Record',
          'body_part': 'chest',
        },
        {
          'id': '0003',
          'name': 'Squat',
          'category': 'upper legs',
          'body_part': 'upper legs',
          'equipment': 'barbell',
          'instructions': {'en': '...'},
          'instruction_steps': {'en': ['...']},
          'muscle_group': 'quadriceps',
          'target': 'quadriceps',
          'media_id': 'def456',
          'image': 'images/0003-def456.jpg',
          'gif_url': 'videos/0003-def456.gif',
          'attribution': '© Gym visual',
          'created_at': '2024-01-01T00:00:00Z',
        },
      ];

      final result = ExerciseParser.parseJsonString(jsonEncode(records));

      expect(result.total, 3);
      expect(result.success, 2);
      expect(result.failed, 1);
      expect(result.exercises, hasLength(2));
    });

    test('deduplicates records with the same id', () {
      const records = [
        {
          'id': '0001',
          'name': 'Bench Press',
          'category': 'chest',
          'body_part': 'chest',
          'equipment': 'barbell',
          'instructions': {'en': '...'},
          'instruction_steps': {'en': ['...']},
          'muscle_group': 'chest',
          'target': 'pectorals',
          'media_id': 'abc123',
          'image': 'images/0001-abc123.jpg',
          'gif_url': 'videos/0001-abc123.gif',
          'attribution': '© Gym visual',
          'created_at': '2024-01-01T00:00:00Z',
        },
        {
          // Same id — should be counted as duplicate.
          'id': '0001',
          'name': 'Duplicate',
          'category': 'chest',
          'body_part': 'chest',
          'equipment': 'barbell',
          'instructions': {'en': '...'},
          'instruction_steps': {'en': ['...']},
          'muscle_group': 'chest',
          'target': 'pectorals',
          'media_id': 'abc123',
          'image': 'images/0001-abc123.jpg',
          'gif_url': 'videos/0001-abc123.gif',
          'attribution': '© Gym visual',
          'created_at': '2024-01-01T00:00:00Z',
        },
      ];

      final result = ExerciseParser.parseJsonString(jsonEncode(records));

      expect(result.total, 2);
      expect(result.success, 1);
      expect(result.duplicated, 1);
      expect(result.exercises, hasLength(1));
      expect(result.exercises.first.name, 'Bench Press');
    });

    test('handles empty array', () {
      final result = ExerciseParser.parseJsonString('[]');

      expect(result.total, 0);
      expect(result.success, 0);
      expect(result.failed, 0);
      expect(result.duplicated, 0);
      expect(result.exercises, isEmpty);
    });

    test('throws ExerciseParserException on malformed JSON', () {
      expect(
        () => ExerciseParser.parseJsonString('{not valid json'),
        throwsA(isA<ExerciseParserException>()),
      );
    });

    test('throws ExerciseParserException when top-level is not an array', () {
      expect(
        () => ExerciseParser.parseJsonString('{"id": "0001"}'),
        throwsA(isA<ExerciseParserException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ExerciseRepository (in-memory drift database)
  // ---------------------------------------------------------------------------

  group('ExerciseRepository', () {
    late AppDatabase db;
    late ExerciseRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ExerciseRepository(db);
    });

    tearDown(() async => db.close());

    test('count returns 0 on empty database', () async {
      expect(await repo.count(), 0);
    });

    test('insertAll inserts exercises and count reflects them', () async {
      final exercises = [
        _makeExercise(id: '0001', name: 'Bench Press'),
        _makeExercise(id: '0002', name: 'Squat', bodyPart: 'upper legs'),
      ];

      await repo.insertAll(exercises);

      expect(await repo.count(), 2);
    });

    test('getById returns the exercise when it exists', () async {
      final exercise = _makeExercise(id: '0001', name: 'Bench Press');
      await repo.insertAll([exercise]);

      final fetched = await repo.getById('0001');

      expect(fetched, isNotNull);
      expect(fetched!.id, '0001');
      expect(fetched.name, 'Bench Press');
    });

    test('getById returns null when exercise does not exist', () async {
      expect(await repo.getById('nonexistent'), isNull);
    });

    test('searchByName matches case-insensitively', () async {
      await repo.insertAll([
        _makeExercise(id: '0001', name: 'Bench Press'),
        _makeExercise(id: '0002', name: 'Incline Bench Press'),
        _makeExercise(id: '0003', name: 'Squat'),
      ]);

      final results = await repo.searchByName('bench');

      expect(results, hasLength(2));
      expect(results.map((e) => e.id).toList(), containsAll(['0001', '0002']));
    });

    test('filter by bodyPart returns matching exercises', () async {
      await repo.insertAll([
        _makeExercise(id: '0001', name: 'Bench Press'),
        _makeExercise(id: '0002', name: 'Squat', bodyPart: 'upper legs'),
        _makeExercise(id: '0003', name: 'Chest Fly'),
      ]);

      final results = await repo.filter(bodyPart: 'chest');

      expect(results, hasLength(2));
      expect(results.every((e) => e.bodyPart == 'chest'), isTrue);
    });

    test('filter by equipment returns matching exercises', () async {
      await repo.insertAll([
        _makeExercise(id: '0001', name: 'Bench Press'),
        _makeExercise(id: '0002', name: 'Fly', equipment: 'dumbbell'),
        _makeExercise(id: '0003', name: 'Cable Fly', equipment: 'cable'),
      ]);

      final results = await repo.filter(equipment: 'barbell');

      expect(results, hasLength(1));
      expect(results.first.name, 'Bench Press');
    });

    test('distinctBodyParts returns sorted unique body parts', () async {
      await repo.insertAll([
        _makeExercise(id: '0001', name: 'A'),
        _makeExercise(id: '0002', name: 'B', bodyPart: 'back'),
        _makeExercise(id: '0003', name: 'C'),
      ]);

      final bodyParts = await repo.distinctBodyParts();

      expect(bodyParts, ['back', 'chest']);
    });

    test('distinctEquipment returns sorted unique equipment', () async {
      await repo.insertAll([
        _makeExercise(id: '0001', name: 'A'),
        _makeExercise(id: '0002', name: 'B', equipment: 'dumbbell'),
        _makeExercise(id: '0003', name: 'C'),
      ]);

      final equipment = await repo.distinctEquipment();

      expect(equipment, ['barbell', 'dumbbell']);
    });

    test('importIfEmpty returns null when table is already populated', () async {
      // Pre-populate the table.
      await repo.insertAll([
        _makeExercise(id: '9999', name: 'Pre-existing'),
      ]);

      // importIfEmpty should detect the existing row and skip.
      final result = await repo.importIfEmpty();

      expect(result, isNull);
      expect(await repo.count(), 1);
    });
  });
}

/// Builds a minimal valid [ExerciseModel] for tests.
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
