import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_model.dart';
import '../repositories/recently_viewed_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// State for the recently-viewed list page.
sealed class RecentlyViewedState {
  const RecentlyViewedState();
}

class RecentlyViewedLoading extends RecentlyViewedState {
  const RecentlyViewedLoading();
}

class RecentlyViewedData extends RecentlyViewedState {
  const RecentlyViewedData(this.exercises);

  final List<ExerciseModel> exercises;
}

class RecentlyViewedError extends RecentlyViewedState {
  const RecentlyViewedError(this.message);

  final String message;
}

/// Notifier that manages the recently-viewed list.
class RecentlyViewedListNotifier extends Notifier<RecentlyViewedState> {
  late RecentlyViewedRepository _repo;

  @override
  RecentlyViewedState build() {
    _repo = ref.watch(recentlyViewedRepositoryProvider);
    unawaited(_load());
    return const RecentlyViewedLoading();
  }

  Future<void> _load() async {
    try {
      final exercises = await _repo.recent(limit: 50);
      if (!ref.mounted) return;
      state = RecentlyViewedData(exercises);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Failed to load recently viewed', e, st);
      state = RecentlyViewedError(e.toString());
    }
  }

  /// Reloads the list from the database.
  Future<void> refresh() => _load();

  /// Clears all recently-viewed history and refreshes the list.
  Future<void> clearAll() async {
    await _repo.clear();
    await _load();
  }
}

/// Provider that exposes the [RecentlyViewedListNotifier].
final recentlyViewedListProvider =
    NotifierProvider<RecentlyViewedListNotifier, RecentlyViewedState>(
  RecentlyViewedListNotifier.new,
);
