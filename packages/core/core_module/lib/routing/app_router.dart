import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'routes.dart';

/// Main application router using GoRouter
@singleton
class AppRouter {
  final List<RouteBase> _routes = [];
  late final GoRouter _router;

  /// Get the GoRouter instance
  GoRouter get router => _router;

  /// Initialize the app router
  @factoryMethod
  static AppRouter init() {
    final router = AppRouter._();
    return router;
  }

  AppRouter._() {
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => _errorPage(context, state),
    );
  }

  /// Add routes to the router
  void addRoutes(List<RouteBase> routes) {
    _routes.addAll(routes);
    _router = GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => _errorPage(context, state),
    );
  }

  /// Error page for when routes aren't found
  Widget _errorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _router.go(Routes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
} 