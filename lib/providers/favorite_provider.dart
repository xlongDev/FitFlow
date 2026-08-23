import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_model.dart';
import '../repositories/favorite_repository.dart';
import '../utils/app_logger.dart';
import 'database_providers.dart';

/// State for the favorites list page.
sealed class FavoriteListState {
  const FavoriteListState();
}

class FavoriteListLoading extends FavoriteListState {
  const FavoriteListLoading();
}

class FavoriteListData extends FavoriteListState {
  const FavoriteListData(this.favorites);

  final List<ExerciseModel> favorites;
}

class FavoriteListError extends FavoriteListState {
  const FavoriteListError(this.message);

  final String message;
}

/// Notifier that manages the favorites list.
///
/// Exposes the current favorites as [FavoriteListData] and provides methods
/// to refresh, search, and toggle individual favorites. When a favorite is
/// toggled, the list is refreshed so the UI stays in sync.
class FavoriteListNotifier extends Notifier<FavoriteListState> {
  late FavoriteRepository _repo;

  @override
  FavoriteListState build() {
    _repo = ref.watch(favoriteRepositoryProvider);
    unawaited(_load());
    return const FavoriteListLoading();
  }

  Future<void> _load() async {
    try {
      final favorites = await _repo.all();
      if (!ref.mounted) return;
      state = FavoriteListData(favorites);
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Failed to load favorites', e, st);
      state = FavoriteListError(e.toString());
    }
  }

  /// Reloads the favorites list from the database.
  Future<void> refresh() => _load();

  /// Toggles the favorite state of [exerciseId] and refreshes the list.
  ///
  /// Returns `true` if the exercise is now favorited.
  Future<bool> toggle(String exerciseId) async {
    final isFav = await _repo.toggle(exerciseId);
    await _load();
    return isFav;
  }

  /// Removes [exerciseId] from favorites and refreshes the list.
  Future<void> remove(String exerciseId) async {
    await _repo.remove(exerciseId);
    await _load();
  }

  /// Clears all favorites and refreshes the list.
  Future<void> clearAll() async {
    await _repo.clear();
    await _load();
  }
}

/// Provider that exposes the [FavoriteListNotifier].
final favoriteListProvider =
    NotifierProvider<FavoriteListNotifier, FavoriteListState>(
  FavoriteListNotifier.new,
);

/// Family provider that tracks whether a single exercise is favorited.
///
/// Usage:
/// ```dart
/// final isFav = ref.watch(isFavoriteProvider('0001'));
/// ```
///
/// Returns `AsyncValue<bool>` — `true` when the exercise is in favorites.
/// The detail page watches this to render the heart icon state.
final isFavoriteProvider =
    FutureProvider.family<bool, String>((ref, exerciseId) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.isFavorite(exerciseId);
});
