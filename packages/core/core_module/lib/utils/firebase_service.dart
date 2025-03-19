import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'logger.dart';

/// Service to initialize and manage Firebase services
@singleton
class FirebaseService {
  final FirebaseCrashlytics? _crashlytics;
  final FirebaseAnalytics _analytics;
  
  /// Constructor
  FirebaseService({
    FirebaseCrashlytics? crashlytics,
    required FirebaseAnalytics analytics,
  }) : _crashlytics = crashlytics,
       _analytics = analytics;
  
  /// Initialize Firebase
  static Future<FirebaseService> init() async {
    await Firebase.initializeApp();
    
    final analytics = FirebaseAnalytics.instance;
    FirebaseCrashlytics? crashlytics;
    
    // Only use Crashlytics in non-debug mode and if platform is supported
    if (!kDebugMode) {
      try {
        crashlytics = FirebaseCrashlytics.instance;
        // Pass all uncaught errors to Crashlytics
        FlutterError.onError = crashlytics.recordFlutterFatalError;
        // Enable Crashlytics data collection
        await crashlytics.setCrashlyticsCollectionEnabled(true);
      } catch (e) {
        // Crashlytics might not be available on all platforms
        print('Crashlytics initialization failed: $e');
      }
    }
    
    return FirebaseService(
      crashlytics: crashlytics,
      analytics: analytics,
    );
  }
  
  /// Get the Crashlytics instance
  FirebaseCrashlytics? get crashlytics => _crashlytics;
  
  /// Get the Analytics instance
  FirebaseAnalytics get analytics => _analytics;
  
  /// Set user identifier for both Crashlytics and Analytics
  Future<void> setUserIdentifier(String? userId) async {
    if (_crashlytics != null && !kDebugMode) {
      await _crashlytics!.setUserIdentifier(userId ?? 'anonymous');
    }
    
    await _analytics.setUserId(id: userId);
  }
  
  /// Log error to Crashlytics
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (_crashlytics != null && !kDebugMode) {
      await _crashlytics!.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    }
  }
  
  /// Configure error handling
  void configureErrorHandling(AppLogger logger) {
    // Handle Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // Forward to crashlytics in non-debug mode
      if (!kDebugMode && _crashlytics != null) {
        _crashlytics!.recordFlutterFatalError(details);
      }
    };
    
    // Handle Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e(
        'Dart error',
        error: error,
        stackTrace: stack,
      );
      
      // Forward to crashlytics in non-debug mode
      if (!kDebugMode && _crashlytics != null) {
        _crashlytics!.recordError(error, stack, fatal: true);
      }
      
      return true;
    };
  }
} 