import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/watch_message_model.dart';
import '../utils/app_logger.dart';
import 'watch_service.dart';

/// The MethodChannel-based WatchConnectivity implementation.
///
/// This is the production implementation used on iOS. It communicates with
/// native Swift code via the `com.fitness_app/watch` channel.
///
/// **Note:** The native iOS side (Swift WatchConnectivity bridge) is not
/// yet implemented — it will be added when we have a macOS + Xcode build
/// environment. Until then, this class compiles but its methods will
/// return `false` / empty streams on iOS. The [MockWatchService] is used
/// as the default fallback.
class IosWatchService implements WatchService {
  IosWatchService();

  static const _channel = MethodChannel('com.fitness_app/watch');

  final _messageController = StreamController<WatchMessageModel>.broadcast();
  final _connectionController =
      StreamController<WatchConnectionState>.broadcast();

  bool _isListening = false;

  @override
  Future<bool> get isAvailable async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosWatchService: isAvailable failed', e);
      return false;
    }
  }

  @override
  Future<bool> get isPaired async {
    try {
      final result = await _channel.invokeMethod<bool>('isPaired');
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosWatchService: isPaired failed', e);
      return false;
    }
  }

  @override
  Future<bool> get isReachable async {
    try {
      final result = await _channel.invokeMethod<bool>('isReachable');
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosWatchService: isReachable failed', e);
      return false;
    }
  }

  @override
  Future<bool> sendMessage(WatchMessageModel message) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'sendMessage',
        message.toJson(),
      );
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosWatchService: sendMessage failed', e);
      return false;
    }
  }

  @override
  Future<bool> sendBackgroundMessage(WatchMessageModel message) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'sendBackgroundMessage',
        message.toJson(),
      );
      return result ?? false;
    } catch (e) {
      AppLogger.w('IosWatchService: sendBackgroundMessage failed', e);
      return false;
    }
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

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onMessageReceived':
          final data = call.arguments as Map<dynamic, dynamic>;
          _messageController.add(
            WatchMessageModel.fromJson(data.cast<String, dynamic>()),
          );
        case 'onConnectionStateChanged':
          final stateStr = call.arguments as String;
          _connectionController.add(_parseState(stateStr));
        default:
          AppLogger.w('IosWatchService: unknown method ${call.method}');
      }
    });

    try {
      unawaited(_channel.invokeMethod<void>('startListening'));
    } catch (e) {
      AppLogger.w('IosWatchService: startListening failed', e);
    }
  }

  @override
  void stopListening() {
    if (!_isListening) return;
    _isListening = false;

    _channel.setMethodCallHandler(null);

    try {
      unawaited(_channel.invokeMethod<void>('stopListening'));
    } catch (e) {
      AppLogger.w('IosWatchService: stopListening failed', e);
    }
  }

  WatchConnectionState _parseState(String state) {
    switch (state) {
      case 'connected':
        return WatchConnectionState.connected;
      case 'sending':
        return WatchConnectionState.sending;
      case 'receiving':
        return WatchConnectionState.receiving;
      default:
        return WatchConnectionState.disconnected;
    }
  }
}
