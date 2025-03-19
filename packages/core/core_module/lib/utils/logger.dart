import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart' as log_package;

/// Log level enum
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Application logger service
@singleton
class AppLogger {
  final log_package.Logger _logger;
  final FirebaseCrashlytics? _crashlytics;
  
  /// Constructor
  AppLogger({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics,
        _logger = log_package.Logger(
          printer: log_package.PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
          filter: kReleaseMode ? log_package.ProductionFilter() : null,
        );
  
  /// Log a verbose message
  void v(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log a debug message
  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log an info message
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Log a warning message
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _recordError(message, error, stackTrace, LogLevel.warning);
  }
  
  /// Log an error message
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _recordError(message, error, stackTrace, LogLevel.error);
  }
  
  /// Log a fatal/critical error message
  void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _recordError(message, error, stackTrace, LogLevel.fatal);
  }
  
  /// Record error to crash reporting service
  void _recordError(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    LogLevel level,
  ) {
    if (_crashlytics != null && !kDebugMode) {
      _crashlytics!.setCustomKey('log_level', level.toString());
      _crashlytics!.setCustomKey('log_message', message);
      
      if (error != null) {
        _crashlytics!.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: level == LogLevel.fatal,
        );
      }
    }
  }
} 