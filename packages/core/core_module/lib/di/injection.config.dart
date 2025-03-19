// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../network/api_client.dart' as _i557;
import '../routing/app_router.dart' as _i282;
import '../storage/local_storage_service.dart' as _i744;
import '../theme/app_theme.dart' as _i1025;
import 'module_registrar.dart' as _i234;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final coreModuleRegistrar = _$CoreModuleRegistrar();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModuleRegistrar.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i282.AppRouter>(() => _i282.AppRouter.init());
    gh.singleton<_i1025.AppTheme>(() => _i1025.AppTheme());
    gh.lazySingleton<_i557.ApiClient>(() => _i557.ApiClient());
    gh.singleton<_i744.LocalStorageService>(
        () => _i744.LocalStorageService(gh<_i460.SharedPreferences>()));
    
    // Manual registration for FirebaseService, FirebaseCrashlytics, and related services
    return this;
  }
}

class _$CoreModuleRegistrar extends _i234.CoreModuleRegistrar {}
