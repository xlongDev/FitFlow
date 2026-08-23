import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_metric_model.freezed.dart';
part 'body_metric_model.g.dart';

/// A single body metric measurement record.
///
/// Captures the user's physical measurements at a point in time. Weight is
/// the primary metric; body fat percentage and circumferences are optional.
/// BMI is computed from weight and height (stored in user profile, future
/// phase) — for now it's stored directly.
@freezed
abstract class BodyMetricModel with _$BodyMetricModel {
  const factory BodyMetricModel({
    /// UUID primary key.
    required String id,

    /// The date this measurement was taken (ISO 8601, day only).
    required String date,

    /// Body weight in kg.
    required double weight,

    /// Body fat percentage (0-100). Null if not measured.
    double? bodyFat,

    /// BMI (computed). Null if height is unknown.
    double? bmi,

    /// Waist circumference in cm.
    double? waist,

    /// Chest circumference in cm.
    double? chest,

    /// Hip circumference in cm.
    double? hip,

    /// Upper arm circumference in cm.
    double? arm,

    /// Thigh circumference in cm.
    double? thigh,

    /// Optional notes.
    @Default('') String notes,

    /// When the record was created (ISO 8601).
    required String createdAt,
  }) = _BodyMetricModel;

  factory BodyMetricModel.fromJson(Map<String, dynamic> json) =>
      _$BodyMetricModelFromJson(json);
}

/// Aggregated trend data for a metric over a time range.
///
/// Used by the progress page to show how a metric (e.g. weight) changed
/// over time — the latest value, the change since the first record, and
/// the percentage change.
class MetricTrend {
  const MetricTrend({
    required this.records,
    required this.latest,
    required this.first,
    required this.change,
    required this.percentChange,
  });

  /// All records in chronological order (oldest first).
  final List<BodyMetricModel> records;

  /// The most recent value.
  final double latest;

  /// The first (oldest) value in the range.
  final double first;

  /// Absolute change (latest - first).
  final double change;

  /// Percentage change ((latest - first) / first * 100).
  final double percentChange;
}
