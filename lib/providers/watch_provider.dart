import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/watch_message_model.dart';
import '../repositories/watch_repository.dart';
import '../services/mock_watch_service.dart';
import '../services/watch_service.dart';
import '../utils/app_logger.dart';

/// State for the watch integration.
sealed class WatchState {
  const WatchState();
}

class WatchInitial extends WatchState {
  const WatchInitial();
}

class WatchChecking extends WatchState {
  const WatchChecking();
}

class WatchDisconnected extends WatchState {
  const WatchDisconnected({required this.isAvailable});

  final bool isAvailable;
}

class WatchConnected extends WatchState {
  const WatchConnected({
    required this.snapshot,
    required this.lastMessage,
  });

  final WatchWorkoutSnapshot snapshot;
  final WatchMessageModel? lastMessage;

  WatchConnected copyWith({
    WatchWorkoutSnapshot? snapshot,
    WatchMessageModel? lastMessage,
  }) {
    return WatchConnected(
      snapshot: snapshot ?? this.snapshot,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

class WatchError extends WatchState {
  const WatchError(this.message);

  final String message;
}

/// Notifier that manages the Apple Watch integration state.
///
/// On first load, checks availability and pairing. If a watch is connected,
/// starts listening for messages and updates the state with live heart rate,
/// calorie, and workout progress data.
class WatchNotifier extends Notifier<WatchState> {
  late WatchRepository _repo;
  StreamSubscription<WatchMessageModel>? _messageSub;

  @override
  WatchState build() {
    _repo = ref.watch(watchRepositoryProvider);
    ref.onDispose(() {
      _messageSub?.cancel().ignore();
      _repo.stopListening();
    });
    unawaited(_checkConnection());
    return const WatchInitial();
  }

  Future<void> _checkConnection() async {
    state = const WatchChecking();

    try {
      final isAvailable = await _repo.isAvailable;
      if (!ref.mounted) return;

      if (!isAvailable) {
        state = const WatchDisconnected(isAvailable: false);
        return;
      }

      final isPaired = await _repo.isPaired;
      if (!ref.mounted) return;

      if (!isPaired) {
        state = const WatchDisconnected(isAvailable: true);
        return;
      }

      // Watch is paired — start listening.
      _repo.startListening();
      _messageSub = _repo.messageStream.listen(_onMessage);

      state = const WatchConnected(
        snapshot: WatchWorkoutSnapshot(),
        lastMessage: null,
      );
    } catch (e, st) {
      if (!ref.mounted) return;
      AppLogger.e('Watch: check failed', e, st);
      state = WatchError(e.toString());
    }
  }

  void _onMessage(WatchMessageModel message) {
    final s = state;
    if (s is! WatchConnected) return;

    switch (message.type) {
      case WatchMessageType.heartRateUpdate:
        final bpm = message.data['bpm'] as int? ?? 0;
        state = s.copyWith(
          snapshot: s.snapshot.copyWith(heartRate: bpm),
          lastMessage: message,
        );

      case WatchMessageType.caloriesUpdate:
        final cal = (message.data['calories'] as num?)?.toDouble() ?? 0;
        state = s.copyWith(
          snapshot: s.snapshot.copyWith(
            calories: s.snapshot.calories + cal,
          ),
          lastMessage: message,
        );

      case WatchMessageType.workoutProgress:
        final completed = message.data['completedSets'] as int?;
        final total = message.data['totalSets'] as int?;
        final exercise = message.data['currentExercise'] as String?;
        state = s.copyWith(
          snapshot: s.snapshot.copyWith(
            completedSets: completed ?? s.snapshot.completedSets,
            totalSets: total ?? s.snapshot.totalSets,
            currentExercise: exercise ?? s.snapshot.currentExercise,
          ),
          lastMessage: message,
        );

      case WatchMessageType.workoutEnded:
        AppLogger.i('Watch: workout ended by user');
        state = s.copyWith(lastMessage: message);

      case WatchMessageType.pong:
        AppLogger.d('Watch: received pong');

      default:
        state = s.copyWith(lastMessage: message);
    }
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// Starts a workout on the watch.
  Future<void> startWorkout({required int totalSets}) async {
    await _repo.startWorkout(totalSets: totalSets);
  }

  /// Stops the workout on the watch.
  Future<void> stopWorkout() async {
    await _repo.stopWorkout();
  }

  /// Updates the current exercise on the watch.
  Future<void> updateExercise({
    required String exerciseName,
    required int setNumber,
    required int totalSets,
  }) async {
    await _repo.updateExercise(
      exerciseName: exerciseName,
      setNumber: setNumber,
      totalSets: totalSets,
    );
  }

  /// Starts a rest timer on the watch.
  Future<void> startRestTimer({required int seconds}) async {
    await _repo.startRestTimer(seconds: seconds);
  }

  /// Cancels the rest timer on the watch.
  Future<void> cancelRestTimer() async {
    await _repo.cancelRestTimer();
  }

  /// Sends a ping to test the connection.
  Future<void> ping() async {
    await _repo.ping();
  }

  /// Refreshes the connection state.
  Future<void> refresh() => _checkConnection();
}

/// Provider that exposes the [WatchNotifier].
final watchProvider =
    NotifierProvider<WatchNotifier, WatchState>(WatchNotifier.new);

/// Provides the [WatchService] implementation.
///
/// On iOS, this would return [IosWatchService]. On all other platforms
/// (and in tests), it returns [MockWatchService].
///
/// **Note:** [IosWatchService] is not yet wired up because the native
/// Swift WatchConnectivity bridge hasn't been implemented.
final watchServiceProvider = Provider<WatchService>((ref) {
  // When the iOS native bridge is ready, uncomment this:
  // if (defaultTargetPlatform == TargetPlatform.iOS) {
  //   return IosWatchService();
  // }
  if (kDebugMode) {
    AppLogger.d('WatchService: using MockWatchService '
        '(platform: $defaultTargetPlatform)');
  }
  return MockWatchService();
});

/// Provides the [WatchRepository], backed by [watchServiceProvider].
final watchRepositoryProvider = Provider<WatchRepository>((ref) {
  final service = ref.watch(watchServiceProvider);
  return WatchRepository(service);
});
