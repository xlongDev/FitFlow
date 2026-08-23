import 'dart:async';

import '../models/watch_message_model.dart';

/// Abstract interface for communicating with the Apple Watch.
///
/// On iOS, the real implementation ([IosWatchService]) uses
/// WatchConnectivity via a MethodChannel. On other platforms (or when no
/// watch is paired), the [MockWatchService] is used — it simulates watch
/// messages so the app can be developed and tested without a physical
/// Apple Watch.
///
/// The UI / Repository layer depends on this abstract interface, never on
/// the concrete implementation. This keeps WatchConnectivity code out of
/// the business logic and makes the watch feature testable.
abstract interface class WatchService {
  /// Whether the platform supports Apple Watch communication.
  ///
  /// Returns `false` on Android / Web / desktop. On iOS, returns `true`
  /// even before the watch is paired — the user may pair one later.
  Future<bool> get isAvailable;

  /// Whether an Apple Watch is currently paired and the app is installed.
  Future<bool> get isPaired;

  /// Whether the watch app is currently reachable (awake + in foreground).
  Future<bool> get isReachable;

  /// Sends a message to the watch.
  ///
  /// Returns `true` if the message was delivered. On iOS, this uses
  /// `WCSession.sendMessage`. The watch must be reachable for this to
  /// succeed — if not, use [sendBackgroundMessage] instead.
  Future<bool> sendMessage(WatchMessageModel message);

  /// Sends a message that will be delivered even if the watch is not
  /// currently reachable (queued for later delivery).
  ///
  /// On iOS, this uses `WCSession.transferUserInfo`.
  Future<bool> sendBackgroundMessage(WatchMessageModel message);

  /// A stream of messages received from the watch.
  ///
  /// Emits a [WatchMessageModel] every time the watch sends a message
  /// (e.g. heart rate update, workout progress). The stream is
  /// single-subscription — only one listener should be active at a time.
  Stream<WatchMessageModel> get messageStream;

  /// A stream of connection state changes.
  Stream<WatchConnectionState> get connectionStateStream;

  /// Starts listening for watch messages. Must be called before
  /// [messageStream] emits any events.
  void startListening();

  /// Stops listening for watch messages and cleans up resources.
  void stopListening();
}
