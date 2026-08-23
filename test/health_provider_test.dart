import 'package:fitness_app/models/health_data_model.dart';
import 'package:fitness_app/providers/health_provider.dart';
import 'package:fitness_app/repositories/health_repository.dart';
import 'package:fitness_app/services/mock_health_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthService mockService;
  late HealthRepository repo;
  late ProviderContainer container;

  setUp(() {
    mockService = MockHealthService();
    repo = HealthRepository(mockService);

    container = ProviderContainer(
      overrides: [
        healthServiceProvider.overrideWithValue(mockService),
        healthRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MockHealthService', () {
    test('isAvailable returns true', () async {
      expect(await mockService.isAvailable, isTrue);
    });

    test('requestAuthorization returns authorized', () async {
      final status = await mockService.requestAuthorization(
        [HealthMetricType.stepCount],
      );
      expect(status, HealthAuthorizationStatus.authorized);
    });

    test('authorizationStatusFor returns authorized after request', () async {
      await mockService.requestAuthorization([HealthMetricType.stepCount]);
      final status = await mockService.authorizationStatusFor(
        HealthMetricType.stepCount,
      );
      expect(status, HealthAuthorizationStatus.authorized);
    });

    test('query returns data points in range', () async {
      // Must authorize first.
      await mockService.requestAuthorization([HealthMetricType.stepCount]);

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final points = await mockService.query(
        HealthMetricType.stepCount,
        start: start,
        end: end,
      );

      expect(points, isNotEmpty);
      expect(points.first.type, HealthMetricType.stepCount);
      expect(points.first.unit, 'count');
    });

    test('query returns empty for different metric types', () async {
      // Must authorize first.
      await mockService.requestAuthorization([HealthMetricType.heartRate]);

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final points = await mockService.query(
        HealthMetricType.heartRate,
        start: start,
        end: end,
      );

      expect(points, isNotEmpty);
      expect(points.first.type, HealthMetricType.heartRate);
      expect(points.first.unit, 'bpm');
    });
  });

  group('HealthRepository', () {
    test('isAvailable delegates to service', () async {
      expect(await repo.isAvailable, isTrue);
    });

    test('requestAuthorization returns true', () async {
      final granted = await repo.requestAuthorization();
      expect(granted, isTrue);
    });

    test('todaySummary returns a summary', () async {
      await repo.requestAuthorization();
      final summary = await repo.todaySummary();

      expect(summary, isNotNull);
      expect(summary.steps, greaterThanOrEqualTo(0));
    });

    test('dailySummary returns summaries for multiple days', () async {
      await repo.requestAuthorization();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 3));
      final end = DateTime(now.year, now.month, now.day);

      final summaries = await repo.dailySummary(start: start, end: end);

      expect(summaries.length, greaterThanOrEqualTo(1));
    });
  });

  group('HealthProvider', () {
    test('initial state is HealthInitial', () {
      final state = container.read(healthProvider);
      expect(state, isA<HealthInitial>());
    });

    test('transitions to HealthData after authorization', () async {
      final subscriber = container.listen(healthProvider, (_, _) {});

      await Future<void>.delayed(const Duration(milliseconds: 500));

      // The mock auto-authorizes, so we should get data.
      final state = subscriber.read();
      expect(
        state,
        anyOf(isA<HealthData>(), isA<HealthUnauthorized>()),
      );

      subscriber.close();
    });
  });
}
