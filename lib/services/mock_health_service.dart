import 'dart:math';

import '../models/health_data_model.dart';
import '../utils/app_logger.dart';
import 'health_service.dart';

/// A [HealthService] that returns deterministic mock data.
///
/// Used when:
///   * The platform is not iOS (Android / Web / desktop).
///   * HealthKit is not available on the device.
///   * Running tests.
///
/// The mock data is deterministic (seeded by date) so the UI looks
/// realistic during development. Each call to [query] returns data points
/// spread across the requested range.
class MockHealthService implements HealthService {
  MockHealthService();

  /// Controls whether the mock pretends to be authorized.
  ///
  /// Set to `true` in tests after calling [requestAuthorization].
  bool _isAuthorized = false;

  @override
  Future<bool> get isAvailable async {
    // The mock is always "available" — it's the fallback when real
    // HealthKit isn't. This lets the UI show the health dashboard even
    // on Android / desktop / CI.
    return true;
  }

  @override
  Future<HealthAuthorizationStatus> requestAuthorization(
    List<HealthMetricType> types,
  ) async {
    // Simulate the user granting access after a short delay.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _isAuthorized = true;
    AppLogger.i('MockHealthService: authorized ${types.length} types');
    return HealthAuthorizationStatus.authorized;
  }

  @override
  Future<HealthAuthorizationStatus> authorizationStatusFor(
    HealthMetricType type,
  ) async {
    return _isAuthorized
        ? HealthAuthorizationStatus.authorized
        : HealthAuthorizationStatus.notDetermined;
  }

  @override
  Future<List<HealthDataPointModel>> query(
    HealthMetricType type, {
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_isAuthorized) return [];

    // Simulate a network / HealthKit query delay.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Generate deterministic mock data based on the date range.
    final days = end.difference(start).inDays + 1;
    final random = Random(start.millisecondsSinceEpoch ~/ 86400000);

    final points = <HealthDataPointModel>[];

    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final value = _generateValue(type, random);
      if (value == null) continue;

      points.add(HealthDataPointModel(
        type: type,
        value: value,
        unit: _unitFor(type),
        startDate: dayStart.toIso8601String(),
        endDate: dayEnd.toIso8601String(),
        source: _sourceFor(type),
      ));
    }

    AppLogger.d('MockHealthService: returned ${points.length} points '
        'for ${type.name}');
    return points;
  }

  /// Generates a realistic mock value for the given metric type.
  double? _generateValue(HealthMetricType type, Random random) {
    switch (type) {
      case HealthMetricType.stepCount:
        // 3000–15000 steps/day
        return 3000 + random.nextDouble() * 12000;
      case HealthMetricType.heartRate:
        // 60–100 bpm (resting)
        return 60 + random.nextDouble() * 40;
      case HealthMetricType.activeEnergy:
        // 200–800 kcal/day
        return 200 + random.nextDouble() * 600;
      case HealthMetricType.restingEnergy:
        // 1400–2000 kcal/day
        return 1400 + random.nextDouble() * 600;
      case HealthMetricType.bodyWeight:
        // 65–85 kg (stable ±0.5)
        return 75 + (random.nextDouble() - 0.5);
      case HealthMetricType.bodyFatPercentage:
        // 12–25%
        return 12 + random.nextDouble() * 13;
      case HealthMetricType.distanceWalkingRunning:
        // 2–12 km/day (in meters)
        return 2000 + random.nextDouble() * 10000;
      case HealthMetricType.flightsClimbed:
        // 0–20 flights/day
        return random.nextDouble() * 20;
      case HealthMetricType.oxygenSaturation:
        // 95–100%
        return 95 + random.nextDouble() * 5;
    }
  }

  String _unitFor(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.stepCount:
        return 'count';
      case HealthMetricType.heartRate:
        return 'bpm';
      case HealthMetricType.activeEnergy:
      case HealthMetricType.restingEnergy:
        return 'kcal';
      case HealthMetricType.bodyWeight:
        return 'kg';
      case HealthMetricType.bodyFatPercentage:
      case HealthMetricType.oxygenSaturation:
        return '%';
      case HealthMetricType.distanceWalkingRunning:
        return 'm';
      case HealthMetricType.flightsClimbed:
        return 'count';
    }
  }

  String _sourceFor(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.stepCount:
      case HealthMetricType.distanceWalkingRunning:
      case HealthMetricType.flightsClimbed:
        return 'iPhone';
      case HealthMetricType.heartRate:
      case HealthMetricType.activeEnergy:
      case HealthMetricType.oxygenSaturation:
        return 'Apple Watch';
      default:
        return 'Health';
    }
  }
}
