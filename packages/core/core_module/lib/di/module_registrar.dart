import 'package:core_module/di/injection.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract class for feature modules to implement for registering dependencies
abstract class ModuleRegistrar {
  /// Register module dependencies
  Future<void> register();
}

/// Manager for handling all module registrations
class ModuleRegistrarManager {
  /// Single instance of the manager
  static final ModuleRegistrarManager _instance = ModuleRegistrarManager._();
  
  /// Singleton constructor
  factory ModuleRegistrarManager() => _instance;
  
  ModuleRegistrarManager._();
  
  /// List of registered modules
  final List<ModuleRegistrar> _modules = [];
  
  /// Add a module to the manager
  void addModule(ModuleRegistrar module) {
    _modules.add(module);
  }
  
  /// Register all modules
  Future<void> registerAll() async {
    for (final module in _modules) {
      await module.register();
    }
  }
}

/// Core module dependencies registrar
@module
abstract class CoreModuleRegistrar {
  /// Register SharedPreferences as a singleton
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
} 