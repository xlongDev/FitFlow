import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance.
///
/// Replaces `print()` everywhere in the codebase. In debug builds it prints
/// pretty output to the console; in release builds it is a no-op so no
/// sensitive data leaks into production logs.
///
/// Usage:
/// ```dart
/// AppLogger.d('exercise imported: $id');
/// AppLogger.e('database open failed', error: e, stackTrace: st);
/// ```
final Logger _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    lineLength: 100,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kDebugMode ? Level.trace : Level.off,
  filter: _AppFilter(),
);

class _AppFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) return true;
    return event.level.index >= Level.error.index;
  }
}

/// Thin wrapper around the underlying [Logger] so call sites don't import
/// the `logger` package directly — keeping the logging API centralized
/// makes it trivial to swap implementations later (e.g. to a remote logger).
class AppLogger {
  AppLogger._();

  static void t(dynamic message) => _logger.t(message);
  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
