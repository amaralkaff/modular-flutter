import 'package:get_it/get_it.dart';
import '../routing/app_router.dart';
import '../storage/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/analytics_service.dart';
import '../utils/firebase_service.dart';
import '../utils/logger.dart';
import 'module_registrar.dart';

/// Registrar for Core Module dependencies
class CoreModuleInitializer implements ModuleRegistrar {
  final GetIt _getIt;

  CoreModuleInitializer(this._getIt);

  @override
  Future<void> register() async {
    // Register core services if they haven't been registered yet
    if (!_getIt.isRegistered<AppRouter>()) {
      _getIt.registerSingleton<AppRouter>(AppRouter.init());
    }

    // Register AppTheme
    if (!_getIt.isRegistered<AppTheme>()) {
      _getIt.registerSingleton<AppTheme>(AppTheme());
    }

    // Register other core services if needed
    // These services are typically registered in the app_dependencies.dart file,
    // but they can also be registered here if they haven't been registered yet
    
    // Register any additional core module dependencies here
    await _registerAdditionalDependencies();
    
    return Future.value();
  }

  Future<void> _registerAdditionalDependencies() async {
    // Add any additional dependencies that need to be registered
    // This method can be extended as needed
    return Future.value();
  }
} 