import 'package:go_router/go_router.dart';

/// Abstract class for feature modules to provide their routes
abstract class RouteProvider {
  /// Get the routes for this module
  List<RouteBase> get routes;
}

/// Manager for collecting all module routes
class RouteProviderManager {
  /// Singleton instance
  static final RouteProviderManager _instance = RouteProviderManager._();
  
  /// Factory constructor for singleton
  factory RouteProviderManager() => _instance;
  
  RouteProviderManager._();
  
  /// List of route providers
  final List<RouteProvider> _providers = [];
  
  /// Add a route provider
  void addProvider(RouteProvider provider) {
    _providers.add(provider);
  }
  
  /// Get all routes from all providers
  List<RouteBase> getAllRoutes() {
    final routes = <RouteBase>[];
    for (final provider in _providers) {
      routes.addAll(provider.routes);
    }
    return routes;
  }
} 