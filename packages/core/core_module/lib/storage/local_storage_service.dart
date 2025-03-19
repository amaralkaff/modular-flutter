import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Box names for Hive
class HiveBoxes {
  HiveBoxes._();
  
  /// User data box
  static const String user = 'user';
  
  /// Cart items box
  static const String cart = 'cart';
  
  /// Order history box
  static const String orders = 'orders';
  
  /// Restaurant favorites box
  static const String favorites = 'favorites';
  
  /// App settings box
  static const String settings = 'settings';
  
  /// Offline data cache box
  static const String cache = 'cache';
}

/// Storage keys for SharedPreferences
class PreferenceKeys {
  PreferenceKeys._();
  
  /// Authentication token
  static const String authToken = 'auth_token';
  
  /// User ID
  static const String userId = 'user_id';
  
  /// User language preference
  static const String language = 'language';
  
  /// Theme mode
  static const String themeMode = 'theme_mode';
  
  /// Last used address
  static const String lastAddress = 'last_address';
  
  /// User onboarding status
  static const String onboardingCompleted = 'onboarding_completed';
  
  /// Notification permission status
  static const String notificationsEnabled = 'notifications_enabled';
}

/// Local storage service
@singleton
class LocalStorageService {
  final SharedPreferences _prefs;
  
  /// Constructor
  LocalStorageService(this._prefs);
  
  /// Initialize local storage
  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    
    // Register adapters for custom types
    // TODO: Register Hive adapters for models
    // Hive.registerAdapter(UserAdapter());
    // Hive.registerAdapter(CartItemAdapter());
    // Hive.registerAdapter(OrderAdapter());
    
    // Open boxes
    await Future.wait([
      Hive.openBox(HiveBoxes.user),
      Hive.openBox(HiveBoxes.cart),
      Hive.openBox(HiveBoxes.orders),
      Hive.openBox(HiveBoxes.favorites),
      Hive.openBox(HiveBoxes.settings),
      Hive.openBox(HiveBoxes.cache),
    ]);
    
    final prefs = await SharedPreferences.getInstance();
    
    return LocalStorageService(prefs);
  }
  
  /// Get a Hive box by name
  Box getBox(String boxName) {
    return Hive.box(boxName);
  }
  
  /// Get SharedPreferences instance
  SharedPreferences get prefs => _prefs;
  
  // SharedPreferences methods
  
  /// Save a string value
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  /// Get a boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  /// Get an integer value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  /// Save a double value
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  /// Get a double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  /// Save a string list
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }
  
  /// Get a string list
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
  
  /// Remove a value
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  /// Clear all stored preferences
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  /// Save auth token
  Future<bool> saveAuthToken(String token) async {
    return await setString(PreferenceKeys.authToken, token);
  }
  
  /// Get auth token
  String? getAuthToken() {
    return getString(PreferenceKeys.authToken);
  }
  
  /// Save user ID
  Future<bool> saveUserId(String userId) async {
    return await setString(PreferenceKeys.userId, userId);
  }
  
  /// Get user ID
  String? getUserId() {
    return getString(PreferenceKeys.userId);
  }
  
  /// Check if user is logged in
  bool isLoggedIn() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Clear auth data
  Future<void> clearAuthData() async {
    await remove(PreferenceKeys.authToken);
    await remove(PreferenceKeys.userId);
  }
} 