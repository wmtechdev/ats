import 'package:flutter/foundation.dart';

/// Enhanced logger utility for real-time debugging
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', data: {'userId': '123'});
/// AppLogger.error('Failed to load data', error: e, stackTrace: stack);
/// AppLogger.debug('Button clicked', tag: 'AppTextField');
/// ```
class AppLogger {
  AppLogger._();

  static const bool _enableLogging = kDebugMode;
  static const String _infoEmoji = 'ℹ️';
  static const String _successEmoji = '✅';
  static const String _warningEmoji = '⚠️';
  static const String _errorEmoji = '❌';
  static const String _debugEmoji = '🔵';

  /// Log info messages
  static void info(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (!_enableLogging) return;
    _log(_infoEmoji, 'INFO', message, tag: tag, data: data);
  }

  /// Log success messages
  static void success(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (!_enableLogging) return;
    _log(_successEmoji, 'SUCCESS', message, tag: tag, data: data);
  }

  /// Log warning messages
  static void warning(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
  }) {
    if (!_enableLogging) return;
    _log(_warningEmoji, 'WARNING', message, tag: tag, data: data, error: error);
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging) return;
    _log(
      _errorEmoji,
      'ERROR',
      message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log debug messages (most verbose)
  static void debug(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    if (!_enableLogging) return;
    _log(_debugEmoji, 'DEBUG', message, tag: tag, data: data);
  }

  /// Internal log method
  static void _log(
    String emoji,
    String level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final tagPrefix = tag != null ? '[$tag]' : '';
    
    // Build log message
    final buffer = StringBuffer();
    buffer.writeln('$emoji [$level] $tagPrefix $message');
    buffer.write('   ⏰ Time: $timestamp');
    
    if (data != null && data.isNotEmpty) {
      buffer.writeln();
      buffer.write('   📦 Data:');
      data.forEach((key, value) {
        buffer.writeln();
        buffer.write('      • $key: $value');
      });
    }
    
    if (error != null) {
      buffer.writeln();
      buffer.write('   ⚠️ Error: $error');
    }
    
    if (stackTrace != null) {
      buffer.writeln();
      buffer.write('   📍 StackTrace:');
      buffer.writeln(stackTrace.toString());
    }
    
    // Output to console
    debugPrint(buffer.toString());
    
    // Also output error details separately for better visibility
    if (error != null) {
      debugPrint('   └─ Error Details: $error');
    }
  }

  /// Log API requests
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
  }) {
    if (!_enableLogging) return;
    debugPrint('🌐 [API REQUEST] $method $url');
    if (headers != null) {
      debugPrint('   📋 Headers: $headers');
    }
    if (body != null) {
      debugPrint('   📦 Body: $body');
    }
  }

  /// Log API responses
  static void apiResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, dynamic>? data,
    Duration? duration,
  }) {
    if (!_enableLogging) return;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    debugPrint('$emoji [API RESPONSE] $method $url → $statusCode');
    if (duration != null) {
      debugPrint('   ⏱️ Duration: ${duration.inMilliseconds}ms');
    }
    if (data != null) {
      debugPrint('   📦 Response: $data');
    }
  }

  /// Log navigation events
  static void navigation({
    required String from,
    required String to,
    Map<String, dynamic>? arguments,
  }) {
    if (!_enableLogging) return;
    debugPrint('🧭 [NAVIGATION] $from → $to');
    if (arguments != null) {
      debugPrint('   📦 Arguments: $arguments');
    }
  }

  /// Log state changes
  static void stateChange({
    required String component,
    required String oldState,
    required String newState,
    Map<String, dynamic>? data,
  }) {
    if (!_enableLogging) return;
    debugPrint('🔄 [STATE] $component: $oldState → $newState');
    if (data != null) {
      debugPrint('   📦 Data: $data');
    }
  }
}
