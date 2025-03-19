import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/auth_repository.dart';

/// Routes constants for auth module
class AuthRoutes {
  /// Private constructor to prevent instantiation
  AuthRoutes._();
  
  /// Splash screen route
  static const String splash = '/splash';
  
  /// Login screen route
  static const String login = '/login';
  
  /// Registration screen route
  static const String register = '/register';
  
  /// Password reset screen route
  static const String forgotPassword = '/forgot-password';
  
  /// Home screen route after successful authentication
  static const String home = '/home';
}

/// Middleware to handle authentication state and redirects
class AuthMiddleware {
  final AuthRepository _authRepository;
  
  AuthMiddleware(this._authRepository);
  
  /// Redirects the user based on their authentication state
  String? handleRedirect(BuildContext context, GoRouterState state) {
    // Get current user from auth repository
    final currentUser = _authRepository.currentUser;
    final isLoggedIn = currentUser != null;
    
    // Get current location from the state
    final location = state.matchedLocation;
    
    // Check if the user is in an auth page
    final isAuthPage = location == AuthRoutes.login || 
                       location == AuthRoutes.register || 
                       location == AuthRoutes.forgotPassword;
    
    // Check if on the home page
    final isHomePage = location == AuthRoutes.home;
    
    // Redirect logic
    if (!isLoggedIn) {
      // User is not logged in
      if (!isAuthPage && location != AuthRoutes.splash) {
        // Redirect to login unless already on splash or auth page
        return AuthRoutes.login;
      }
    } else if (isLoggedIn && isAuthPage) {
      // User is logged in but on auth page, redirect to home
      return AuthRoutes.home;
    }
    
    // No redirect needed
    return null;
  }
} 