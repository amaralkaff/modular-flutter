import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Load all environment variables for the application
Future<void> loadEnvironmentVariables() async {
  try {
    // Load the main app's environment variables
    await dotenv.load(fileName: '.env');
    
    if (kDebugMode) {
      print('Environment variables loaded successfully');
      // Only print variable names, not values, for security
      print('Available variables: ${dotenv.env.keys.toList()}');
    }
    
    // Validate essential environment variables
    _validateRequiredEnvVariables();
  } catch (e) {
    debugPrint('Error loading environment variables: $e');
    // Create default environment values for development if needed
    if (kDebugMode) {
      debugPrint('Using default environment values for development');
      // You might want to set default values for development
      // dotenv.env['SOME_KEY'] = 'default_value';
    }
  }
}

/// Validate that all required environment variables are present
void _validateRequiredEnvVariables() {
  final requiredVariables = [
    'MAPBOX_ACCESS_TOKEN',
    // Add other required variables here
  ];
  
  final missingVariables = requiredVariables
      .where((variable) => dotenv.env[variable]?.isEmpty ?? true)
      .toList();
  
  if (missingVariables.isNotEmpty) {
    debugPrint('WARNING: Missing required environment variables: $missingVariables');
  }
} 