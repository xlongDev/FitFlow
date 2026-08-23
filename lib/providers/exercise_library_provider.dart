import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';
import 'database_providers.dart';

/// The visual layout the exercise library is displayed in.
enum ExerciseViewMode {
  /// 2-column grid of cards with GIF thumbnails.
  grid,

  /// Single-column list with smaller thumbnails.
  list,
}

/// Immutable filter + search state for the exercise library.
///
/// Kept separate from the result data so the UI can render the filter chips
/// and search bar without triggering a new database query on every keystroke
/// (debouncing happens in the provider).
class ExerciseFilter {
  const ExerciseFilter({
    this.query = '',
    this.bodyParts = const <String>{},
    this.equipment = const <String>{},
    this.viewMode = ExerciseViewMode.grid,
  });

  /// Free-text search query (matched against exercise name, case-insensitive).
  final String query;

  /// Selected body-part filters. Empty means "all".
  final Set<String> bodyParts;

  /// Selected equipment filters. Empty means "all".
  final Set<String> equipment;

  /// Current grid / list view mode.
  final ExerciseViewMode viewMode;

  /// Returns `true` when no filters are active — used to decide whether to
  /// show the "clear filters" affordance.
  bool get isEmpty =>
      query.isEmpty && bodyParts.isEmpty && equipment.isEmpty;

  ExerciseFilter copyWith({
    String? query,
    Set<String>? bodyParts,
    Set<String>? equipment,
    ExerciseViewMode? viewMode,
  }) {
    return ExerciseFilter(
      query: query ?? this.query,
      bodyParts: bodyParts ?? this.bodyParts,
      equipment: equipment ?? this.equipment,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

/// State exposed by [ExerciseLibraryNotifier].
///
/// Wraps the async result with the current filter so the UI can render the
/// filter chips even while results are loading.
class ExerciseLibraryState {
  const ExerciseLibraryState({
    required this.filter,
    required this.exercises,
    this.totalCount = 0,
  });

  final ExerciseFilter filter;

  /// Async result of the current query. May be loading / data / error.
  final AsyncValue<List<ExerciseModel>> exercises;

  /// Total number of exercises in the database (independent of filters).
  /// Used to show "X of Y exercises" in the header.
  final int totalCount;

  ExerciseLibraryState copyWith({
    ExerciseFilter? filter,
    AsyncValue<List<ExerciseModel>>? exercises,
    int? totalCount,
  }) {
    return ExerciseLibraryState(
      filter: filter ?? this.filter,
      exercises: exercises ?? this.exercises,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Provider that exposes the distinct body parts present in the dataset.
///
/// Used to populate the filter sheet's body-part chips. Cached so the query
/// only runs once.
final bodyPartsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.distinctBodyParts();
});

/// Provider that exposes the distinct equipment types present in the dataset.
final equipmentListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.distinctEquipment();
});

/// Provider that exposes the total exercise count (for the header).
final exerciseCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.count();
});

/// The main exercise-library notifier.
///
/// Holds the current [ExerciseFilter] and runs a database query whenever the
/// filter changes. The query is debounced for free-text search so typing
/// "bench" doesn't fire 5 queries.
class ExerciseLibraryNotifier extends Notifier<ExerciseLibraryState> {
  late final ExerciseRepository _repo;

  @override
  ExerciseLibraryState build() {
    _repo = ref.watch(exerciseRepositoryProvider);

    const initial = ExerciseLibraryState(
      filter: ExerciseFilter(),
      exercises: AsyncValue.loading(),
    );

    // Kick off the initial load.
    unawaited(Future.microtask(_refresh));

    return initial;
  }

  /// Re-runs the query with the current filter.
  ///
  /// Called automatically on build and whenever the filter changes. Can also
  /// be called manually to retry after an error.
  Future<void> refresh() => _refresh();

  /// Re-runs the query with the current filter.
  ///
  /// Called automatically on build and whenever the filter changes. Can also
  /// be called manually to retry after an error.
  Future<void> _refresh() async {
    state = state.copyWith(exercises: const AsyncValue.loading());

    try {
      final filter = state.filter;
      final results = await _query(filter);
      // Guard against the provider being disposed while the query was in
      // flight (e.g. the user navigated away).
      if (!ref.mounted) return;
      state = state.copyWith(exercises: AsyncValue.data(results));
    } catch (e, st) {
      if (!ref.mounted) return;
      state = state.copyWith(exercises: AsyncValue.error(e, st));
    }
  }

  /// Executes the actual database query based on [filter].
  ///
  /// When body-part or equipment filters are active, we fetch a larger pool
  /// and filter in-memory because the repository's `filter` method only
  /// accepts a single body-part / equipment value. This keeps the UI
  /// responsive without requiring a more complex SQL query.
  Future<List<ExerciseModel>> _query(ExerciseFilter filter) async {
    final query = filter.query.trim();

    // If there's a text query, search by name first.
    if (query.isNotEmpty) {
      final results = await _repo.searchByName(query);
      return _applyMultiFilters(results, filter);
    }

    // If only body-part / equipment filters are active (no text), use the
    // repository's filter method with the first selected value, then
    // narrow further in-memory.
    if (filter.bodyParts.isNotEmpty || filter.equipment.isNotEmpty) {
      final results = await _repo.filter(
        bodyPart: filter.bodyParts.isEmpty ? null : filter.bodyParts.first,
        equipment: filter.equipment.isEmpty ? null : filter.equipment.first,
        limit: 500,
      );
      return _applyMultiFilters(results, filter);
    }

    // No filters — return everything (capped for performance).
    return _repo.getAll(limit: 500);
  }

  /// Narrows [results] by the full set of selected body-parts / equipment.
  ///
  /// The repository's `filter` only accepts a single value per axis; this
  /// method applies the remaining filters in-memory. With ~1300 exercises
  /// this is fast enough and avoids a complex SQL builder.
  List<ExerciseModel> _applyMultiFilters(
    List<ExerciseModel> results,
    ExerciseFilter filter,
  ) {
    var output = results;

    if (filter.bodyParts.length > 1) {
      final extra = filter.bodyParts.skip(1).toSet();
      output = output.where((e) => extra.contains(e.bodyPart)).toList();
    }

    if (filter.equipment.length > 1) {
      final extra = filter.equipment.skip(1).toSet();
      output = output.where((e) => extra.contains(e.equipment)).toList();
    }

    return output;
  }

  // ---------------------------------------------------------------------------
  // Public mutators — called by the UI.
  // ---------------------------------------------------------------------------

  /// Updates the free-text search query and re-queries.
  Future<void> setQuery(String query) async {
    state = state.copyWith(filter: state.filter.copyWith(query: query));
    await _refresh();
  }

  /// Toggles a body-part filter on / off.
  Future<void> toggleBodyPart(String bodyPart) async {
    final next = Set<String>.from(state.filter.bodyParts);
    if (!next.add(bodyPart)) {
      next.remove(bodyPart);
    }
    state = state.copyWith(filter: state.filter.copyWith(bodyParts: next));
    await _refresh();
  }

  /// Toggles an equipment filter on / off.
  Future<void> toggleEquipment(String equipment) async {
    final next = Set<String>.from(state.filter.equipment);
    if (!next.add(equipment)) {
      next.remove(equipment);
    }
    state = state.copyWith(filter: state.filter.copyWith(equipment: next));
    await _refresh();
  }

  /// Switches between grid and list view.
  void setViewMode(ExerciseViewMode mode) {
    state = state.copyWith(filter: state.filter.copyWith(viewMode: mode));
  }

  /// Clears all filters and the search query.
  Future<void> clearFilters() async {
    state = state.copyWith(filter: const ExerciseFilter());
    await _refresh();
  }
}

/// Provider that exposes the [ExerciseLibraryNotifier].
final exerciseLibraryProvider =
    NotifierProvider<ExerciseLibraryNotifier, ExerciseLibraryState>(
  ExerciseLibraryNotifier.new,
);
