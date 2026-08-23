import 'dart:async';

import '../models/watch_message_model.dart';
import '../services/watch_service.dart';
import '../utils/app_logger.dart';

/// Data-access layer for Apple Watch communication.
///
/// Wraps [WatchService] and provides higher-level methods for the workout
/// session flow: starting/stopping workouts, updating the current exercise,
/// and listening for live heart rate / calorie updates from the watch.
///
/// The UI layer goes through this repository via a Riverpod provider —
/// never touches [WatchService] directly.
class WatchRepository {
  WatchRepository(this._service);

  final WatchService _service;

  /// Whether the platform supports Apple Watch.
  Future<bool> get isAvailable => _service.isAvailable;

  /// Whether a watch is paired and the app is installed.
  Future<bool> get isPaired => _service.isPaired;

  /// Whether the watch is currently reachable.
  Future<bool> get isReachable => _service.isReachable;

  /// Starts listening for watch messages.
  void startListening() => _service.startListening();

  /// Stops listening for watch messages.
  void stopListening() => _service.stopListening();

  /// Stream of messages received from the watch.
  Stream<WatchMessageModel> get messageStream => _service.messageStream;

  /// Stream of connection state changes.
  Stream<WatchConnectionState> get connectionStateStream =>
      _service.connectionStateStream;

  // ---------------------------------------------------------------------------
  // Workout commands
  // ---------------------------------------------------------------------------

  /// Tells the watch to start a workout session.
  ///
  /// [totalSets] is the total number of sets in the workout so the watch
  /// can show a progress bar.
  Future<bool> startWorkout({required int totalSets}) async {
    final message = WatchMessageModel(
      type: WatchMessageType.startWorkout,
      data: {'totalSets': totalSets},
      timestamp: DateTime.now().toIso8601String(),
    );
    final sent = await _service.sendMessage(message);
    AppLogger.i('WatchRepository: startWorkout (sent=$sent)');
    return sent;
  }

  /// Tells the watch to stop the current workout.
  Future<bool> stopWorkout() async {
    final message = WatchMessageModel(
      type: WatchMessageType.stopWorkout,
      data: {},
      timestamp: DateTime.now().toIso8601String(),
    );
    final sent = await _service.sendMessage(message);
    AppLogger.i('WatchRepository: stopWorkout (sent=$sent)');
    return sent;
  }

  /// Updates the current exercise shown on the watch.
  Future<bool> updateExercise({
    required String exerciseName,
    required int setNumber,
    required int totalSets,
  }) async {
    final message = WatchMessageModel(
      type: WatchMessageType.updateExercise,
      data: {
        'exerciseName': exerciseName,
        'setNumber': setNumber,
        'totalSets': totalSets,
      },
      timestamp: DateTime.now().toIso8601String(),
    );
    return _service.sendMessage(message);
  }

  /// Starts a rest timer on the watch.
  Future<bool> startRestTimer({required int seconds}) async {
    final message = WatchMessageModel(
      type: WatchMessageType.startRestTimer,
      data: {'seconds': seconds},
      timestamp: DateTime.now().toIso8601String(),
    );
    return _service.sendMessage(message);
  }

  /// Cancels the rest timer on the watch.
  Future<bool> cancelRestTimer() async {
    final message = WatchMessageModel(
      type: WatchMessageType.cancelRestTimer,
      data: {},
      timestamp: DateTime.now().toIso8601String(),
    );
    return _service.sendMessage(message);
  }

  /// Sends a ping to test the connection.
  Future<bool> ping() async {
    final message = WatchMessageModel(
      type: WatchMessageType.ping,
      data: {},
      timestamp: DateTime.now().toIso8601String(),
    );
    return _service.sendMessage(message);
  }
}
