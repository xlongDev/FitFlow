import '../models/health_data_model.dart';

/// Abstract interface for reading health data from the platform.
///
/// On iOS, the real implementation ([IosHealthService]) uses a MethodChannel
/// to call HealthKit via native Swift code. On other platforms (or when
/// HealthKit is unavailable), the [MockHealthService] is used instead — it
/// returns deterministic mock data so the UI can be developed and tested
/// without a physical device.
///
/// The UI / Repository layer depends on this abstract interface, never on
/// the concrete implementation. This keeps HealthKit code out of the
/// business logic and makes the health feature testable.
abstract interface class HealthService {
  /// Whether the platform supports Apple Health.
  ///
  /// Returns `false` on Android / Web / desktop. On iOS, returns `true`
  /// even before authorization — the user may not have granted access yet.
  Future<bool> get isAvailable;

  /// Requests authorization to read the given [types].
  ///
  /// On iOS, this triggers the HealthKit permission dialog. Returns the
  /// authorization status after the user responds.
  Future<HealthAuthorizationStatus> requestAuthorization(
    List<HealthMetricType> types,
  );

  /// Returns the current authorization status for [type].
  Future<HealthAuthorizationStatus> authorizationStatusFor(
    HealthMetricType type,
  );

  /// Reads all data points of [type] in the given [start]–[end] range.
  ///
  /// Returns an empty list if the user hasn't authorized access or if no
  /// data exists in the range.
  Future<List<HealthDataPointModel>> query(
    HealthMetricType type, {
    required DateTime start,
    required DateTime end,
  });
}
