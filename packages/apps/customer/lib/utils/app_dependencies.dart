import 'package:auth/auth.dart';
import 'package:auth/di/auth_module_registrar.dart';
import 'package:core_module/core_module.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restaurant_catalog/restaurant_catalog.dart';
import '../app_routes.dart';
import 'package:core_module/di/core_module_registrar.dart';
import 'package:core_module/user_preference/user_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Setup all app dependencies and register modules
Future<void> setupAppDependencies() async {
  final getIt = GetIt.instance;
  
  // Core services setup
  final firebaseService = await FirebaseService.init();
  await LocalStorageService.init();
  
  // Register Firebase services
  if (!getIt.isRegistered<FirebaseService>()) {
    getIt.registerSingleton<FirebaseService>(firebaseService);
  }
  
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  }
  
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  }
  
  if (!getIt.isRegistered<FirebaseStorage>()) {
    getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  }
  
  if (!getIt.isRegistered<FirebaseAnalytics>()) {
    getIt.registerSingleton<FirebaseAnalytics>(firebaseService.analytics);
  }
  
  if (!getIt.isRegistered<AnalyticsService>()) {
    getIt.registerSingleton<AnalyticsService>(AnalyticsService(firebaseService.analytics));
  }
  
  if (!getIt.isRegistered<AppLogger>()) {
    getIt.registerSingleton<AppLogger>(AppLogger(crashlytics: firebaseService.crashlytics));
  }
  
  // Set up Firebase emulator if needed
  final useEmulator = dotenv.env['FIREBASE_USE_EMULATOR']?.toLowerCase() == 'true';
  if (useEmulator) {
    _setupFirebaseEmulators();
  }
  
  // Register feature modules
  final authModuleRegistrar = AuthModuleRegistrar(getIt);
  await authModuleRegistrar.register();
  
  // Register restaurant catalog module
  final restaurantCatalogModuleRegistrar = RestaurantCatalogModuleRegistrar(getIt);
  await restaurantCatalogModuleRegistrar.register();
  
  // Register core module
  final coreModuleInitializer = CoreModuleInitializer(getIt);
  await coreModuleInitializer.register();
  
  // TODO: Uncomment when live tracking module is properly linked
  // Setup live tracking module
  // setupLiveTrackingModule();
  
  // Configure error handling
  firebaseService.configureErrorHandling(getIt<AppLogger>());
  
  // Initialize app router
  final appRouter = getIt<AppRouter>();
  
  // Configure auth middleware
  final authBloc = getIt<AuthBloc>();
  appRouter.setRedirect((context, state) {
    // Handle redirects based on authentication state
    final authState = authBloc.state;
    if (authState is Unauthenticated && !state.matchedLocation.contains('/login')) {
      return '/login';
    }
    return null;
  });
  
  // Register routes
  if (!_routesInitialized) {
    final routeProvider = CustomerAppRoutes();
    appRouter.addRoutes(routeProvider.routes);
    _routesInitialized = true;
  }

  // Note: Mapbox is now initialized in main.dart to avoid duplicate initialization
}

/// Set up Firebase emulators for local development
void _setupFirebaseEmulators() {
  const emulatorHost = 'localhost';
  
  try {
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
    
    debugPrint('✅ Connected to Firebase Emulators');
  } catch (e) {
    debugPrint('⚠️ Failed to connect to Firebase Emulators: $e');
  }
}

/// Global variable to prevent double initialization
bool _routesInitialized = false; 