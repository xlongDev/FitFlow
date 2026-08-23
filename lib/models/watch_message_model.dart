import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch_message_model.freezed.dart';
part 'watch_message_model.g.dart';

/// The type of message exchanged between the Flutter app and the Apple Watch.
///
/// Each message type maps to a specific WatchConnectivity action on iOS.
/// The Flutter app sends [WatchMessageType] commands to the watch, and the
/// watch sends back [WatchMessageType] responses or events.
enum WatchMessageType {
  /// App → Watch: start a workout session.
  startWorkout,

  /// App → Watch: stop the current workout session.
  stopWorkout,

  /// App → Watch: update the current exercise being performed.
  updateExercise,

  /// App → Watch: start a rest timer.
  startRestTimer,

  /// App → Watch: cancel the rest timer.
  cancelRestTimer,

  /// Watch → App: heart rate reading.
  heartRateUpdate,

  /// Watch → App: workout progress update.
  workoutProgress,

  /// Watch → App: calories burned update.
  caloriesUpdate,

  /// Watch → App: workout session ended by the user (from the watch).
  workoutEnded,

  /// Bidirectional: ping/pong for connection testing.
  ping,
  pong,
}

/// A message exchanged between the Flutter app and the Apple Watch.
///
/// Messages are JSON-serializable so they can be sent over WatchConnectivity's
/// `sendMessage` API. The [type] field identifies the message purpose; the
/// [data] map carries the payload (e.g. exercise name, heart rate value).
@freezed
abstract class WatchMessageModel with _$WatchMessageModel {
  const factory WatchMessageModel({
    /// The message type — determines how [data] is interpreted.
    required WatchMessageType type,

    /// The message payload. Keys depend on [type]:
    ///   * startWorkout: {'planName': String, 'dayName': String}
    ///   * updateExercise: {'exerciseName': String, 'setNumber': int, 'reps': String}
    ///   * startRestTimer: {'seconds': int}
    ///   * heartRateUpdate: {'bpm': int, 'timestamp': String}
    ///   * workoutProgress: {'completedSets': int, 'totalSets': int}
    ///   * caloriesUpdate: {'calories': double}
    @Default(<String, dynamic>{}) Map<String, dynamic> data,

    /// When the message was created (ISO 8601).
    required String timestamp,
  }) = _WatchMessageModel;

  factory WatchMessageModel.fromJson(Map<String, dynamic> json) =>
      _$WatchMessageModelFromJson(json);
}

/// The connection state of the Apple Watch.
enum WatchConnectionState {
  /// The watch is not paired or the app is not installed on the watch.
  disconnected,

  /// The watch is paired and the app is installed, but not actively
  /// communicating.
  connected,

  /// A message is being sent to the watch.
  sending,

  /// A message was received from the watch.
  receiving,
}

/// A snapshot of the current workout state on the watch.
///
/// Sent from the watch to the app during an active workout session so the
/// app can display live heart rate, calories, and progress.
class WatchWorkoutSnapshot {
  const WatchWorkoutSnapshot({
    this.heartRate = 0,
    this.calories = 0,
    this.completedSets = 0,
    this.totalSets = 0,
    this.currentExercise = '',
    this.elapsedSeconds = 0,
  });

  final int heartRate;
  final double calories;
  final int completedSets;
  final int totalSets;
  final String currentExercise;
  final int elapsedSeconds;

  WatchWorkoutSnapshot copyWith({
    int? heartRate,
    double? calories,
    int? completedSets,
    int? totalSets,
    String? currentExercise,
    int? elapsedSeconds,
  }) {
    return WatchWorkoutSnapshot(
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
      completedSets: completedSets ?? this.completedSets,
      totalSets: totalSets ?? this.totalSets,
      currentExercise: currentExercise ?? this.currentExercise,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
