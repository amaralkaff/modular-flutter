// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as _i141;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../network/api_client.dart' as _i557;
import '../routing/app_router.dart' as _i282;
import '../storage/local_storage_service.dart' as _i744;
import '../theme/app_theme.dart' as _i1025;
import '../utils/analytics_service.dart' as _i76;
import '../utils/firebase_service.dart' as _i223;
import '../utils/logger.dart' as _i221;
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
    gh.singleton<_i223.FirebaseService>(() => _i223.FirebaseService(
          crashlytics: gh<_i141.FirebaseCrashlytics>(),
          analytics: gh<_i398.FirebaseAnalytics>(),
        ));
    gh.singleton<_i221.AppLogger>(
        () => _i221.AppLogger(crashlytics: gh<_i141.FirebaseCrashlytics>()));
    gh.singleton<_i76.AnalyticsService>(
        () => _i76.AnalyticsService(gh<_i398.FirebaseAnalytics>()));
    return this;
  }
}

class _$CoreModuleRegistrar extends _i234.CoreModuleRegistrar {}
