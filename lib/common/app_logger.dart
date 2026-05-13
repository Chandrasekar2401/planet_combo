import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Lightweight application-wide logger.
///
/// Routes messages through `dart:developer` so they show up correctly in
/// the DevTools log view (with proper level filtering and stack traces),
/// while gating verbose output behind [kDebugMode] so release builds stay
/// quiet. Use a [tag] to identify the source area (controller, screen,
/// service, etc.) — it makes the logs greppable.
class AppLogger {
  AppLogger._();

  static const String _appName = 'PlanetCombo';

  static const int _levelDebug = 500;
  static const int _levelInfo = 800;
  static const int _levelWarning = 900;
  static const int _levelError = 1000;

  /// Verbose diagnostic information. Stripped from release builds.
  static void d(Object? message, {String tag = _appName}) {
    if (!kDebugMode) return;
    _log(message, tag: tag, level: _levelDebug);
  }

  /// Normal application flow events worth keeping in the log.
  static void i(Object? message, {String tag = _appName}) {
    _log(message, tag: tag, level: _levelInfo);
  }

  /// Recoverable problems, deprecated paths, or suspicious states.
  static void w(Object? message,
      {String tag = _appName, Object? error, StackTrace? stackTrace}) {
    _log(message,
        tag: tag,
        level: _levelWarning,
        error: error,
        stackTrace: stackTrace);
  }

  /// Errors and exceptions. Always logged, in debug and release.
  static void e(Object? message,
      {String tag = _appName, Object? error, StackTrace? stackTrace}) {
    _log(message,
        tag: tag,
        level: _levelError,
        error: error,
        stackTrace: stackTrace);
  }

  static void _log(
    Object? message, {
    required String tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message?.toString() ?? 'null',
      name: tag,
      level: level,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }
}
