import 'package:auth/auth.dart';
import 'package:get_it/get_it.dart';

/// Auth module registrar that registers all dependencies for the auth module
class AuthModuleRegistrar {
  final GetIt _getIt;
  
  AuthModuleRegistrar(this._getIt);
  
  Future<void> register() async {
    // Register services
    if (!_getIt.isRegistered<AuthService>()) {
      _getIt.registerLazySingleton<AuthService>(() => AuthService());
    }
    
    // Register repositories
    if (!_getIt.isRegistered<AuthRepository>()) {
      _getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(_getIt<AuthService>()),
      );
    }
    
    // Register auth middleware
    if (!_getIt.isRegistered<AuthMiddleware>()) {
      _getIt.registerLazySingleton<AuthMiddleware>(
        () => AuthMiddleware(_getIt<AuthRepository>()),
      );
    }
    
    // Register BLoCs
    if (!_getIt.isRegistered<AuthBloc>()) {
      _getIt.registerFactory<AuthBloc>(
        () => AuthBloc(_getIt<AuthRepository>()),
      );
    }
  }
} 