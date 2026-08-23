import '../models/health_data_model.dart';
import '../services/health_service.dart';
import '../utils/app_logger.dart';

/// Data-access layer for Apple Health data.
///
/// Wraps [HealthService] and provides higher-level query methods that
/// aggregate raw data points into daily summaries. The UI layer goes
/// through this repository via a Riverpod provider — never touches
/// [HealthService] directly.
class HealthRepository {
  HealthRepository(this._service);

  final HealthService _service;

  /// Whether Apple Health is available on this platform.
  Future<bool> get isAvailable => _service.isAvailable;

  /// Requests authorization for all supported metric types.
  ///
  /// Returns `true` if the user granted access.
  Future<bool> requestAuthorization() async {
    const types = HealthMetricType.values;
    final status = await _service.requestAuthorization(types);
    AppLogger.i('HealthRepository: authorization status = $status');
    return status == HealthAuthorizationStatus.authorized;
  }

  /// Returns the authorization status for a single metric type.
  Future<HealthAuthorizationStatus> authorizationStatusFor(
    HealthMetricType type,
  ) {
    return _service.authorizationStatusFor(type);
  }

  /// Queries raw data points for [type] in the given range.
  Future<List<HealthDataPointModel>> query(
    HealthMetricType type, {
    required DateTime start,
    required DateTime end,
  }) {
    return _service.query(type, start: start, end: end);
  }

  /// Returns a daily summary for the given date range.
  ///
  /// Aggregates step count, active energy, heart rate, and distance into
  /// a single [DailyHealthSummary] per day.
  Future<List<DailyHealthSummary>> dailySummary({
    required DateTime start,
    required DateTime end,
  }) async {
    final days = end.difference(start).inDays + 1;
    final summaries = <DailyHealthSummary>[];

    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Query multiple metrics in parallel for speed.
      final results = await Future.wait([
        _service.query(HealthMetricType.stepCount, start: dayStart, end: dayEnd),
        _service.query(HealthMetricType.activeEnergy, start: dayStart, end: dayEnd),
        _service.query(HealthMetricType.heartRate, start: dayStart, end: dayEnd),
        _service.query(HealthMetricType.distanceWalkingRunning, start: dayStart, end: dayEnd),
        _service.query(HealthMetricType.flightsClimbed, start: dayStart, end: dayEnd),
      ]);

      final steps = results[0].fold(0.0, (sum, p) => sum + p.value);
      final energy = results[1].fold(0.0, (sum, p) => sum + p.value);
      final hrValues = results[2].map((p) => p.value).toList();
      final distance = results[3].fold(0.0, (sum, p) => sum + p.value);
      final flights = results[4].fold(0.0, (sum, p) => sum + p.value);

      summaries.add(DailyHealthSummary(
        date: dayStart,
        steps: steps.round(),
        activeEnergy: energy,
        heartRate: hrValues.isEmpty ? 0 : (hrValues.reduce((a, b) => a + b) / hrValues.length).round(),
        distance: distance,
        flightsClimbed: flights.round(),
      ));
    }

    return summaries;
  }

  /// Returns today's summary (a convenience method for the dashboard).
  Future<DailyHealthSummary> todaySummary() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final summaries = await dailySummary(start: today, end: today);
    return summaries.isEmpty
        ? DailyHealthSummary(date: today)
        : summaries.first;
  }
}
