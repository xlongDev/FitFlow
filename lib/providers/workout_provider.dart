import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session_model.dart';
import '../repositories/workout_repository.dart';
import 'database_providers.dart';

/// State for the active workout session.
sealed class WorkoutSessionState {
  const WorkoutSessionState();
}

/// No active session — the user hasn't started a workout.
class WorkoutIdle extends WorkoutSessionState {
  const WorkoutIdle();
}

/// A session is in progress.
class WorkoutActive extends WorkoutSessionState {
  const WorkoutActive({
    required this.sessionId,
    required this.startedAt,
    required this.sets,
    required this.elapsedSeconds,
  });

  final String sessionId;
  final DateTime startedAt;
  final List<SetRecordModel> sets;
  final int elapsedSeconds;

  /// Total volume of completed sets.
  double get totalVolume => sets
      .where((s) => s.isCompleted)
      .fold(0.0, (sum, s) => sum + s.weight * s.reps);

  /// Number of completed sets.
  int get completedSets => sets.where((s) => s.isCompleted).length;

  WorkoutActive copyWith({
    List<SetRecordModel>? sets,
    int? elapsedSeconds,
  }) {
    return WorkoutActive(
      sessionId: sessionId,
      startedAt: startedAt,
      sets: sets ?? this.sets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

/// Notifier that manages the active workout session.
///
/// Holds the current session state (idle / active), a live elapsed-time
/// timer, and methods to start / finish / abandon the session and add /
/// toggle / remove sets.
class WorkoutSessionNotifier extends Notifier<WorkoutSessionState> {
  late WorkoutRepository _repo;
  Timer? _timer;

  @override
  WorkoutSessionState build() {
    _repo = ref.watch(workoutRepositoryProvider);
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const WorkoutIdle();
  }

  /// Starts a new workout session.
  Future<void> startSession({
    String? scheduledWorkoutId,
    String? planDayId,
    String? planId,
    String? planName,
    String? dayName,
  }) async {
    final sessionId = await _repo.startSession(
      scheduledWorkoutId: scheduledWorkoutId,
      planDayId: planDayId,
      planId: planId,
      planName: planName,
      dayName: dayName,
    );

    final startedAt = DateTime.now();
    state = WorkoutActive(
      sessionId: sessionId,
      startedAt: startedAt,
      sets: const <SetRecordModel>[],
      elapsedSeconds: 0,
    );

    // Start the elapsed-time timer.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is WorkoutActive) {
        final active = state as WorkoutActive;
        state = active.copyWith(elapsedSeconds: active.elapsedSeconds + 1);
      }
    });
  }

  /// Finishes the session: persists completion, stops the timer.
  Future<void> finishSession() async {
    final s = state;
    if (s is! WorkoutActive) return;

    _timer?.cancel();
    await _repo.finishSession(s.sessionId);
    state = const WorkoutIdle();
  }

  /// Abandons the session without recording completion.
  Future<void> abandonSession() async {
    final s = state;
    if (s is! WorkoutActive) return;

    _timer?.cancel();
    await _repo.abandonSession(s.sessionId);
    state = const WorkoutIdle();
  }

  /// Adds a set to the active session.
  Future<void> addSet({
    required String exerciseId,
    required String exerciseName,
    required int setNumber,
    required double weight,
    required int reps,
  }) async {
    final s = state;
    if (s is! WorkoutActive) return;

    final setId = await _repo.addSet(
      sessionId: s.sessionId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
    );

    final newSet = SetRecordModel(
      id: setId,
      sessionId: s.sessionId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      recordedAt: DateTime.now().toIso8601String(),
    );

    state = s.copyWith(sets: [...s.sets, newSet]);
  }

  /// Toggles a set's completion state.
  Future<void> toggleSetCompletion(String setId) async {
    final s = state;
    if (s is! WorkoutActive) return;

    await _repo.toggleSetCompletion(setId);

    final newSets = s.sets.map((set) {
      if (set.id == setId) {
        return set.copyWith(isCompleted: !set.isCompleted);
      }
      return set;
    }).toList();

    state = s.copyWith(sets: newSets);
  }

  /// Removes a set from the active session.
  Future<void> removeSet(String setId) async {
    final s = state;
    if (s is! WorkoutActive) return;

    await _repo.removeSet(setId);
    state = s.copyWith(sets: s.sets.where((set) => set.id != setId).toList());
  }

  /// Updates a set's weight and reps.
  Future<void> updateSet(SetRecordModel updated) async {
    final s = state;
    if (s is! WorkoutActive) return;

    await _repo.updateSet(updated);
    state = s.copyWith(
      sets: s.sets.map((set) => set.id == updated.id ? updated : set).toList(),
    );
  }
}

/// Provider that exposes the [WorkoutSessionNotifier].
final workoutSessionProvider =
    NotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>(
  WorkoutSessionNotifier.new,
);

/// Provider that loads completed sessions for the history page.
final workoutHistoryProvider = FutureProvider<List<WorkoutSessionModel>>((
  ref,
) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.completedSessions();
});
