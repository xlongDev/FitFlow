import 'package:drift/native.dart';
import 'package:fitness_app/database/app_database.dart';
import 'package:fitness_app/models/body_metric_model.dart';
import 'package:fitness_app/providers/body_metric_provider.dart';
import 'package:fitness_app/providers/database_providers.dart';
import 'package:fitness_app/repositories/body_metric_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late BodyMetricRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BodyMetricRepository(db);

    container = ProviderContainer(
      overrides: [
        bodyMetricRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('BodyMetricRepository', () {
    test('add and all', () async {
      final now = DateTime.now();
      final metric = BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day).toIso8601String(),
        weight: 75.0,
        bodyFat: 18.5,
        createdAt: now.toIso8601String(),
      );

      await repo.add(metric);

      final all = await repo.all();
      expect(all, hasLength(1));
      expect(all.first.weight, 75.0);
      expect(all.first.bodyFat, 18.5);
    });

    test('all returns newest first', () async {
      final now = DateTime.now();

      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day - 2).toIso8601String(),
        weight: 76.0,
        createdAt: now.toIso8601String(),
      ));
      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day).toIso8601String(),
        weight: 74.0,
        createdAt: now.toIso8601String(),
      ));

      final all = await repo.all();
      expect(all.first.weight, 74.0);
    });

    test('remove deletes a record', () async {
      final now = DateTime.now();
      final metric = BodyMetricModel(
        id: repo.newId(),
        date: now.toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      );

      await repo.add(metric);
      await repo.remove(metric.id);

      final all = await repo.all();
      expect(all, isEmpty);
    });

    test('computeTrend returns null with < 2 records', () async {
      final now = DateTime.now();
      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: now.toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      ));

      final trend = await repo.computeTrend((m) => m.weight);
      expect(trend, isNull);
    });

    test('computeTrend calculates change and percentChange', () async {
      final now = DateTime.now();

      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day - 7).toIso8601String(),
        weight: 80.0,
        createdAt: now.toIso8601String(),
      ));
      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day).toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      ));

      final trend = await repo.computeTrend((m) => m.weight);

      expect(trend, isNotNull);
      expect(trend!.first, 80.0);
      expect(trend.latest, 75.0);
      expect(trend.change, -5.0);
      expect(trend.percentChange, closeTo(-6.25, 0.01));
    });

    test('computeTrend skips null values', () async {
      final now = DateTime.now();

      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day - 7).toIso8601String(),
        weight: 80.0,
        bodyFat: 20.0,
        createdAt: now.toIso8601String(),
      ));
      await repo.add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day).toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      ));

      final trend = await repo.computeTrend((m) => m.bodyFat);

      expect(trend, isNull);
    });
  });

  group('BodyDataProvider', () {
    test('initial state is loading', () {
      final state = container.read(bodyDataProvider);
      expect(state, isA<BodyDataLoading>());
    });

    test('add refreshes the state', () async {
      final subscriber = container.listen(bodyDataProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final now = DateTime.now();
      await container.read(bodyDataProvider.notifier).add(BodyMetricModel(
        id: repo.newId(),
        date: DateTime(now.year, now.month, now.day).toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read();
      expect(state, isA<BodyDataData>());

      subscriber.close();
    });

    test('remove refreshes the state', () async {
      final subscriber = container.listen(bodyDataProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final now = DateTime.now();
      final metric = BodyMetricModel(
        id: repo.newId(),
        date: now.toIso8601String(),
        weight: 75.0,
        createdAt: now.toIso8601String(),
      );
      await container.read(bodyDataProvider.notifier).add(metric);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await container.read(bodyDataProvider.notifier).remove(metric.id);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = subscriber.read() as BodyDataData;
      expect(state.records, isEmpty);

      subscriber.close();
    });
  });
}
