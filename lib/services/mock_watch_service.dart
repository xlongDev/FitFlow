import 'dart:async';
import 'dart:math';

import '../models/watch_message_model.dart';
import '../utils/app_logger.dart';
import 'watch_service.dart';

/// A [WatchService] that simulates Apple Watch communication.
///
/// Used when:
///   * The platform is not iOS (Android / Web / desktop).
///   * No Apple Watch is paired.
///   * Running tests.
///
/// The mock simulates a connected watch that responds to workout commands
/// with periodic heart rate, calorie, and progress updates. This lets the
/// app's watch integration be developed and tested without a physical
/// watch.
class MockWatchService implements WatchService {
  MockWatchService();

  final _messageController = StreamController<WatchMessageModel>.broadcast();
  final _connectionController =
      StreamController<WatchConnectionState>.broadcast();

  bool _isListening = false;
  bool _workoutActive = false;
  Timer? _simulationTimer;
  final _random = Random();

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<bool> get isPaired async => true;

  @override
  Future<bool> get isReachable async => true;

  @override
  Future<bool> sendMessage(WatchMessageModel message) async {
    AppLogger.d('MockWatchService: received ${message.type}');

    // Simulate the watch responding to certain message types.
    switch (message.type) {
      case WatchMessageType.startWorkout:
        _workoutActive = true;
        _connectionController.add(WatchConnectionState.sending);
        _startSimulation();
        // Simulate the watch acknowledging the workout start.
        _emitMessage(WatchMessageType.workoutProgress, {
          'completedSets': 0,
          'totalSets': message.data['totalSets'] ?? 10,
        });
        return true;

      case WatchMessageType.stopWorkout:
        _workoutActive = false;
        _stopSimulation();
        _emitMessage(WatchMessageType.workoutEnded, {});
        return true;

      case WatchMessageType.updateExercise:
        _emitMessage(WatchMessageType.workoutProgress, {
          'currentExercise': message.data['exerciseName'],
        });
        return true;

      case WatchMessageType.startRestTimer:
        // Simulate a rest timer countdown.
        final seconds = message.data['seconds'] as int? ?? 90;
        _simulateRestTimer(seconds);
        return true;

      case WatchMessageType.cancelRestTimer:
        return true;

      case WatchMessageType.ping:
        _emitMessage(WatchMessageType.pong, {});
        return true;

      default:
        return true;
    }
  }

  @override
  Future<bool> sendBackgroundMessage(WatchMessageModel message) async {
    // The mock always "delivers" background messages.
    return true;
  }

  @override
  Stream<WatchMessageModel> get messageStream => _messageController.stream;

  @override
  Stream<WatchConnectionState> get connectionStateStream =>
      _connectionController.stream;

  @override
  void startListening() {
    if (_isListening) return;
    _isListening = true;
    _connectionController.add(WatchConnectionState.connected);
    AppLogger.i('MockWatchService: started listening');
  }

  @override
  void stopListening() {
    _isListening = false;
    _stopSimulation();
    _connectionController.add(WatchConnectionState.disconnected);
    AppLogger.i('MockWatchService: stopped listening');
  }

  // ---------------------------------------------------------------------------
  // Simulation
  // ---------------------------------------------------------------------------

  void _startSimulation() {
    _simulationTimer?.cancel();
    // Emit heart rate + calorie updates every 3 seconds during a workout.
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_workoutActive) return;

      // Simulate heart rate: 120-170 bpm during exercise.
      final hr = 120 + _random.nextInt(50);
      _emitMessage(WatchMessageType.heartRateUpdate, {
        'bpm': hr,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Simulate calories: 0.5-2.0 kcal per update.
      final cal = 0.5 + _random.nextDouble() * 1.5;
      _emitMessage(WatchMessageType.caloriesUpdate, {
        'calories': cal,
      });
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void _simulateRestTimer(int seconds) {
    var remaining = seconds;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0 || !_workoutActive) {
        timer.cancel();
      }
    });
  }

  void _emitMessage(WatchMessageType type, Map<String, dynamic> data) {
    if (!_isListening) return;
    _messageController.add(WatchMessageModel(
      type: type,
      data: data,
      timestamp: DateTime.now().toIso8601String(),
    ));
  }
}
