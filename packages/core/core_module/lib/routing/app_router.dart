import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'routes.dart';

/// Main application router using GoRouter
@singleton
class AppRouter {
  final List<RouteBase> _routes = [];
  late GoRouter _router;
  bool _isInitialized = false;
  GoRouterRedirect? _redirectLogic;

  /// Get the GoRouter instance
  GoRouter get router => _router;

  /// Initialize the app router
  @factoryMethod
  static AppRouter init() {
    final router = AppRouter._();
    return router;
  }

  AppRouter._() {
    // Create a default router with no routes initially
    _initializeRouter();
  }

  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => _errorPage(context, state),
      redirect: _redirectLogic,
    );
    _isInitialized = true;
  }

  /// Set the redirect logic for the router
  void setRedirect(GoRouterRedirect redirectLogic) {
    _redirectLogic = redirectLogic;
    
    // Recreate the router with the updated redirect logic
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => _errorPage(context, state),
      redirect: _redirectLogic,
    );
    debugPrint('Router updated with redirect logic');
  }

  /// Add routes to the router
  void addRoutes(List<RouteBase> routes) {
    if (routes.isEmpty) {
      debugPrint('No routes to add. Skipping.');
      return;
    }

    // Check if any of the new routes are already added
    final newRoutes = routes.where((route) => 
      !_routes.any((existingRoute) => existingRoute == route)
    ).toList();

    if (newRoutes.isEmpty) {
      debugPrint('All routes already exist. Skipping.');
      return;
    }

    // Add the new routes to our internal list
    _routes.addAll(newRoutes);
    
    // Recreate the router with the updated routes
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => _errorPage(context, state),
      redirect: _redirectLogic,
    );
    debugPrint('Router updated with ${newRoutes.length} new routes.');
  }

  /// Error page for when routes aren't found
  Widget _errorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => router.go(Routes.splash),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
} 