import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../storage/local_storage_service.dart';
export 'user_preference_keys.dart';

/// Service for managing user preferences
@singleton
class UserPreferenceService {
  final LocalStorageService _localStorage;

  /// Keys for user preferences
  static const String _languageKey = 'user_language';
  static const String _themeKey = 'user_theme';
  static const String _notificationsKey = 'user_notifications';
  static const String _locationPermissionKey = 'location_permission';
  static const String _lastKnownLatKey = 'last_known_lat';
  static const String _lastKnownLngKey = 'last_known_lng';

  /// Constructor
  UserPreferenceService(this._localStorage);

  /// Factory method for dependency injection
  @factoryMethod
  static UserPreferenceService init() {
    final localStorage = GetIt.instance<LocalStorageService>();
    return UserPreferenceService(localStorage);
  }

  /// Get the user's preferred language
  Future<String> getLanguage() async {
    return await _localStorage.getString(_languageKey) ?? 'en';
  }

  /// Set the user's preferred language
  Future<void> setLanguage(String languageCode) async {
    await _localStorage.setString(_languageKey, languageCode);
  }

  /// Get whether dark theme is enabled
  Future<bool> isDarkThemeEnabled() async {
    return await _localStorage.getBool(_themeKey) ?? false;
  }

  /// Set dark theme preference
  Future<void> setDarkTheme(bool isDarkTheme) async {
    await _localStorage.setBool(_themeKey, isDarkTheme);
  }

  /// Get whether notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _localStorage.getBool(_notificationsKey) ?? true;
  }

  /// Set notifications preference
  Future<void> setNotificationsEnabled(bool areEnabled) async {
    await _localStorage.setBool(_notificationsKey, areEnabled);
  }

  /// Get whether location permission has been granted
  Future<bool> hasLocationPermission() async {
    return await _localStorage.getBool(_locationPermissionKey) ?? false;
  }

  /// Set location permission status
  Future<void> setLocationPermission(bool hasPermission) async {
    await _localStorage.setBool(_locationPermissionKey, hasPermission);
  }

  /// Save last known location
  Future<void> saveLastKnownLocation(double lat, double lng) async {
    await _localStorage.setDouble(_lastKnownLatKey, lat);
    await _localStorage.setDouble(_lastKnownLngKey, lng);
  }

  /// Get last known location
  Future<Map<String, double?>> getLastKnownLocation() async {
    final lat = await _localStorage.getDouble(_lastKnownLatKey);
    final lng = await _localStorage.getDouble(_lastKnownLngKey);
    return {
      'latitude': lat,
      'longitude': lng,
    };
  }

  /// Clear all user preferences
  Future<void> clearAll() async {
    await _localStorage.remove(_languageKey);
    await _localStorage.remove(_themeKey);
    await _localStorage.remove(_notificationsKey);
    await _localStorage.remove(_locationPermissionKey);
    await _localStorage.remove(_lastKnownLatKey);
    await _localStorage.remove(_lastKnownLngKey);
    debugPrint('All user preferences cleared');
  }
} 