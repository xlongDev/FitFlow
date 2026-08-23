import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_data_model.freezed.dart';
part 'health_data_model.g.dart';

/// The type of health metric being tracked.
///
/// Mirrors Apple Health's HKQuantityTypeIdentifier categories. Each type
/// maps to a specific HealthKit quantity type on iOS.
enum HealthMetricType {
  /// Step count (count).
  stepCount,

  /// Heart rate (bpm).
  heartRate,

  /// Active energy burned (kcal).
  activeEnergy,

  /// Resting energy / basal metabolic rate (kcal).
  restingEnergy,

  /// Body weight (kg).
  bodyWeight,

  /// Body fat percentage (%).
  bodyFatPercentage,

  /// Distance walked/run (m).
  distanceWalkingRunning,

  /// Flights of stairs climbed (count).
  flightsClimbed,

  /// Blood oxygen saturation (%).
  oxygenSaturation,
}

/// A single health data point read from Apple Health.
///
/// Each point captures a metric type, value, unit, and the start/end time
/// of the measurement. HealthKit returns samples with a time range; for
/// instantaneous measurements (like heart rate), start == end.
@freezed
abstract class HealthDataPointModel with _$HealthDataPointModel {
  const factory HealthDataPointModel({
    /// The metric type (e.g. stepCount, heartRate).
    required HealthMetricType type,

    /// The measured value.
    required double value,

    /// The unit of measurement (e.g. 'count', 'bpm', 'kcal', 'kg').
    required String unit,

    /// When the measurement started (ISO 8601).
    required String startDate,

    /// When the measurement ended (ISO 8601).
    required String endDate,

    /// The data source (e.g. 'iPhone', 'Apple Watch').
    @Default('') String source,
  }) = _HealthDataPointModel;

  factory HealthDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$HealthDataPointModelFromJson(json);
}

/// Authorization status for Apple Health access.
enum HealthAuthorizationStatus {
  /// The user hasn't been asked yet.
  notDetermined,

  /// The user denied access to this data type.
  denied,

  /// The user granted access.
  authorized,
}

/// Aggregated health data for a day.
///
/// Computed by summing / averaging all [HealthDataPointModel]s for a given
/// date. Used by the health dashboard to show a daily summary.
class DailyHealthSummary {
  const DailyHealthSummary({
    required this.date,
    this.steps = 0,
    this.activeEnergy = 0,
    this.heartRate = 0,
    this.distance = 0,
    this.flightsClimbed = 0,
  });

  final DateTime date;
  final int steps;
  final double activeEnergy;
  final int heartRate;
  final double distance;
  final int flightsClimbed;
}
