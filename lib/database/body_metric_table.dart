import 'package:drift/drift.dart';

/// The `body_metrics` table — body measurement records over time.
///
/// Each row is one measurement session. Weight is required; all other
/// fields (body fat, BMI, circumferences) are optional. The user can log
/// multiple records per day (e.g. morning / evening weight).
@DataClassName('BodyMetricRow')
class BodyMetrics extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// The date this measurement was taken (ISO 8601, day only).
  TextColumn get date => text()();

  /// Body weight in kg.
  RealColumn get weight => real()();

  /// Body fat percentage (0-100). Null if not measured.
  RealColumn get bodyFat => real().nullable()();

  /// BMI (computed). Null if height is unknown.
  RealColumn get bmi => real().nullable()();

  /// Waist circumference in cm.
  RealColumn get waist => real().nullable()();

  /// Chest circumference in cm.
  RealColumn get chest => real().nullable()();

  /// Hip circumference in cm.
  RealColumn get hip => real().nullable()();

  /// Upper arm circumference in cm.
  RealColumn get arm => real().nullable()();

  /// Thigh circumference in cm.
  RealColumn get thigh => real().nullable()();

  /// Optional notes.
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// When the record was created (ISO 8601).
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
