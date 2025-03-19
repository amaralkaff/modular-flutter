import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  AppColors._();
  
  // Brand colors
  static const Color primary = Color(0xFFFF5722);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFFC107);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Background colors
  static const Color scaffoldBackgroundLight = Color(0xFFF5F5F5);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);
  static const Color cardLight = Colors.white;
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkAppBar = Color(0xFF1E1E1E);
  static const Color darkInputFill = Color(0xFF2C2C2C);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF424242);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF5722),
      Color(0xFFFF8A65),
    ],
  );
  
  // Category colors
  static const Color categoryFastFood = Color(0xFFFF5722);
  static const Color categoryHealthy = Color(0xFF4CAF50);
  static const Color categoryDesserts = Color(0xFFE91E63);
  static const Color categoryBeverages = Color(0xFF2196F3);
  static const Color categoryAsian = Color(0xFFFFC107);
  static const Color categoryItalian = Color(0xFF9C27B0);
} 