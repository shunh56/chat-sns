import 'package:app/core/error/failure.dart';
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static void log({
    required LogLevel level,
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Failure? failure,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    var logMessage = '[$timestamp] $levelStr: $message';

    if (error != null) {
      logMessage += '\nError: $error';
    }

    if (failure != null) {
      logMessage += '\nFailure: ${failure.code} - ${failure.message}';
    }

    if (stackTrace != null && level == LogLevel.error) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    // 本番環境ではクラッシュリポーティングツールに送信するなど
    if (kDebugMode) {
      debugPrint(logMessage);
    } else {
      // 本番環境用のログ記録（Firebase Crashlyticsなど）
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  static void debug({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Failure? failure,
  }) {
    log(
      level: LogLevel.debug,
      message: message,
      error: error,
      stackTrace: stackTrace,
      failure: failure,
    );
  }

  static void info({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Failure? failure,
  }) {
    log(
      level: LogLevel.info,
      message: message,
      error: error,
      stackTrace: stackTrace,
      failure: failure,
    );
  }

  static void warning({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Failure? failure,
  }) {
    log(
      level: LogLevel.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
      failure: failure,
    );
  }

  static void error({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Failure? failure,
  }) {
    log(
      level: LogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
      failure: failure,
    );
  }
}
