import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application.
/// Uses debugPrint in development and can be easily disabled in production.
class AppLogger {
  /// Log informational messages
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    _log('WARNING', message, tag: tag);
  }

  /// Log error messages
  static void error(String message, {String? tag, Object? error}) {
    _log('ERROR', message, tag: tag);
    if (error != null) {
      debugPrint('  Error details: $error');
    }
  }

  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _log('DEBUG', message, tag: tag);
    }
  }

  static void _log(String level, String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('[$level] $tagPrefix$message');
    }
  }
}
