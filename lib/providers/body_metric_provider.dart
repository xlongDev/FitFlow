import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_metric_model.dart';
import '../repositories/body_metric_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// State for the body data page.
sealed class BodyDataState {
  const BodyDataState();
}

class BodyDataLoading extends BodyDataState {
  const BodyDataLoading();
}

class BodyDataData extends BodyDataState {
  const BodyDataData({
    required this.records,
    required this.latest,
    required this.weightTrend,
  });

  /// All records, newest first.
  final List<BodyMetricModel> records;

  /// The most recent record (null if none).
  final BodyMetricModel? latest;

  /// Weight trend (null if < 2 records).
  final MetricTrend? weightTrend;
}

class BodyDataError extends BodyDataState {
  const BodyDataError(this.message);

  final String message;
}

/// Notifier that manages the body data page state.
class BodyDataNotifier extends Notifier<BodyDataState> {
  late BodyMetricRepository _repo;

  @override
  BodyDataState build() {
    _repo = ref.watch(bodyMetricRepositoryProvider);
    unawaited(_load());
    return const BodyDataLoading();
  }

  Future<void> _load() async {
    try {
      final records = await _repo.all();
      final latest = records.isEmpty ? null : records.first;
      final weightTrend = await _repo.computeTrend((m) => m.weight);

      if (!ref.mounted) return;
      state = BodyDataData(
        records: records,
        latest: latest,
        weightTrend: weightTrend,
      );
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('BodyData: failed to load', e, st);
      state = BodyDataError(e.toString());
    }
  }

  /// Adds a new record and refreshes.
  Future<void> add(BodyMetricModel metric) async {
    await _repo.add(metric);
    await _load();
  }

  /// Removes a record and refreshes.
  Future<void> remove(String id) async {
    await _repo.remove(id);
    await _load();
  }

  /// Refreshes the state.
  Future<void> refresh() => _load();
}

/// Provider that exposes the [BodyDataNotifier].
final bodyDataProvider =
    NotifierProvider<BodyDataNotifier, BodyDataState>(BodyDataNotifier.new);

/// Provider that loads body metric records for the progress page's trend chart.
final bodyMetricHistoryProvider =
    FutureProvider<List<BodyMetricModel>>((ref) async {
  final repo = ref.watch(bodyMetricRepositoryProvider);
  return repo.all();
});
