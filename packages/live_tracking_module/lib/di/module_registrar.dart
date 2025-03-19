import 'package:get_it/get_it.dart';
import 'package:live_tracking_module/live_tracking_module.dart';

/// Registrar for the Live Tracking Module that handles DI setup
class LiveTrackingModuleRegistrar {
  final GetIt _getIt;
  
  LiveTrackingModuleRegistrar(this._getIt);
  
  /// Register all dependencies for the Live Tracking Module
  Future<void> register() async {
    // Register services
    _registerServices();
    
    // Register repositories
    _registerRepositories();
    
    // Register BLoCs
    _registerBlocs();
  }
  
  void _registerServices() {
    // Register Mapbox service
    if (!_getIt.isRegistered<MapboxService>()) {
      _getIt.registerLazySingleton<MapboxService>(() => MapboxService());
    }
    
    // Register Location service
    if (!_getIt.isRegistered<LocationService>()) {
      _getIt.registerLazySingleton<LocationService>(() => LocationService());
    }
  }
  
  void _registerRepositories() {
    // Register Map repository
    if (!_getIt.isRegistered<MapRepository>()) {
      _getIt.registerLazySingleton<MapRepository>(
        () => MapboxMapRepository(_getIt<MapboxService>()),
      );
    }
    
    // Register Location repository
    if (!_getIt.isRegistered<LocationRepository>()) {
      _getIt.registerLazySingleton<LocationRepository>(
        () => FirebaseLocationRepository(),
      );
    }
  }
  
  void _registerBlocs() {
    // Register Tracking BLoC
    if (!_getIt.isRegistered<TrackingBloc>()) {
      _getIt.registerFactory<TrackingBloc>(
        () => TrackingBloc(
          mapRepository: _getIt<MapRepository>(),
          locationRepository: _getIt<LocationRepository>(),
        ),
      );
    }
  }
} 