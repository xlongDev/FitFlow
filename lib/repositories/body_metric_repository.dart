import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/body_metric_table.dart';
import '../models/body_metric_model.dart';
import '../utils/app_logger.dart';

/// Data-access layer for body metric records.
///
/// Manages the user's body measurement history (weight, body fat,
/// circumferences). Supports adding new records, querying history, and
/// computing trend data (change over time).
class BodyMetricRepository {
  BodyMetricRepository(this._db);

  final AppDatabase _db;

  /// Adds a new body metric record.
  Future<void> add(BodyMetricModel metric) async {
    await _db.into(_db.bodyMetrics).insert(
          BodyMetricsCompanion.insert(
            id: metric.id,
            date: metric.date,
            weight: metric.weight,
            bodyFat: Value(metric.bodyFat),
            bmi: Value(metric.bmi),
            waist: Value(metric.waist),
            chest: Value(metric.chest),
            hip: Value(metric.hip),
            arm: Value(metric.arm),
            thigh: Value(metric.thigh),
            notes: Value(metric.notes),
            createdAt: metric.createdAt,
          ),
        );
    AppLogger.d('BodyMetric: added record for ${metric.date}');
  }

  /// Removes a record by id.
  Future<void> remove(String id) async {
    await (_db.delete(_db.bodyMetrics)
          ..where((BodyMetrics t) => t.id.equals(id)))
        .go();
  }

  /// Returns all records, newest first.
  Future<List<BodyMetricModel>> all() async {
    final rows = await (_db.select(_db.bodyMetrics)
          ..orderBy([(BodyMetrics t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the most recent record, or `null` if none exist.
  Future<BodyMetricModel?> latest() async {
    final rows = await (_db.select(_db.bodyMetrics)
          ..orderBy([(BodyMetrics t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : _rowToModel(rows.first);
  }

  /// Returns records within a date range, oldest first (for trend charts).
  Future<List<BodyMetricModel>> getRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = _normalizeDate(start).toIso8601String();
    final endStr = _normalizeDate(end).toIso8601String();

    final rows = await (_db.select(_db.bodyMetrics)
          ..where((BodyMetrics t) =>
              t.date.isBetweenValues(startStr, endStr))
          ..orderBy([(BodyMetrics t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Computes the trend for a specific metric field over all records.
  ///
  /// [extractor] selects which numeric field to trend (e.g. weight, bodyFat).
  /// Returns `null` if fewer than 2 records exist.
  Future<MetricTrend?> computeTrend(
    double? Function(BodyMetricModel) extractor,
  ) async {
    final records = await all();
    if (records.length < 2) return null;

    // Reverse to oldest-first.
    final chronological = records.reversed.toList();

    final values = <double>[];
    for (final r in chronological) {
      final v = extractor(r);
      if (v != null) values.add(v);
    }

    if (values.length < 2) return null;

    final first = values.first;
    final latest = values.last;
    final change = latest - first;
    final percentChange = first != 0 ? (change / first) * 100 : 0.0;

    return MetricTrend(
      records: chronological,
      latest: latest,
      first: first,
      change: change,
      percentChange: percentChange,
    );
  }

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  BodyMetricModel _rowToModel(BodyMetricRow r) {
    return BodyMetricModel(
      id: r.id,
      date: r.date,
      weight: r.weight,
      bodyFat: r.bodyFat,
      bmi: r.bmi,
      waist: r.waist,
      chest: r.chest,
      hip: r.hip,
      arm: r.arm,
      thigh: r.thigh,
      notes: r.notes,
      createdAt: r.createdAt,
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _uuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final hex = now.toRadixString(16).padLeft(16, '0');
    return 'body-$hex-${now.toRadixString(36)}';
  }

  /// Generates a new UUID for a body metric record.
  String newId() => _uuid();
}
