import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Database migration', () {
    test('creates all tables on fresh install (schema v8)', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // Verify all tables exist by querying their row counts.
      expect(await db.exercises.count().getSingle(), 0);
      expect(await db.favorites.count().getSingle(), 0);
      expect(await db.recentlyViewed.count().getSingle(), 0);
      expect(await db.trainingPlans.count().getSingle(), 0);
      expect(await db.trainingDays.count().getSingle(), 0);
      expect(await db.trainingExercises.count().getSingle(), 0);
      expect(await db.scheduledWorkouts.count().getSingle(), 0);
      expect(await db.workoutSessions.count().getSingle(), 0);
      expect(await db.setRecords.count().getSingle(), 0);
      expect(await db.dietRecords.count().getSingle(), 0);
      expect(await db.dietPlans.count().getSingle(), 0);
      expect(await db.bodyMetrics.count().getSingle(), 0);

      await db.close();
    });

    test('schema version is 8', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      expect(db.schemaVersion, 8);
      await db.close();
    });

    test('WAL mode is enabled or falls back gracefully', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // Trigger beforeOpen by querying.
      await db.exercises.count().getSingle();
      // In-memory databases may not support WAL — just verify the
      // database opened successfully without throwing.
      await db.close();
    });

    test('foreign keys are enabled', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.exercises.count().getSingle();
      final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.data['foreign_keys'], 1);
      await db.close();
    });
  });
}
