import 'package:core_module/core_module.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:auth/di/auth_module_registrar.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'app_routes.dart';
import 'firebase_options.dart';

/// Global variable to prevent double initialization
bool _routesInitialized = false;

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
      });
      return Material(
        child: Container(
          color: Colors.white,
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
                'An error occurred: ${details.exception}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Material(
            child: Container(
              color: Colors.white,
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
                    'An error occurred: $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
    }
    return widget.child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Print debug package name and platform
    final packageName = Platform.isAndroid ? "com.amangly.app" : "com.example.app";
    debugPrint('Package name: $packageName');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('⚠️ IMPORTANT: For Google Sign-In to work, add your SHA-1 fingerprint to Firebase Console!');
    debugPrint('⚠️ Run: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android');
    
    // Initialize Firebase services
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (firebaseError) {
      debugPrint('Firebase initialization error: $firebaseError');
      // Continue execution - the FirebaseService will handle fallbacks
    }
    
    final firebaseService = await FirebaseService.init();
    debugPrint('FirebaseService initialized');
    
    // Configure dependencies
    await configureDependencies(environment: Env.dev);
    debugPrint('Dependencies configured');
    
    // Initialize local storage (already registered by DI)
    final storageService = await LocalStorageService.init();
    debugPrint('LocalStorage initialized');
    
    // Register services that aren't handled by the DI system
    if (!getIt.isRegistered<FirebaseService>()) {
      getIt.registerSingleton<FirebaseService>(firebaseService);
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
    
    // Register auth module
    final authModuleRegistrar = AuthModuleRegistrar(getIt);
    await authModuleRegistrar.register();
    debugPrint('Auth module registered');
    
    // Configure error handling
    firebaseService.configureErrorHandling(getIt<AppLogger>());
    
    // Initialize app router
    final appRouter = getIt<AppRouter>();
    
    // Configure auth middleware
    final authMiddleware = getIt<AuthMiddleware>();
    appRouter.setRedirect(authMiddleware.handleRedirect);
    debugPrint('Auth middleware configured');
    
    // Only register routes once
    if (!_routesInitialized) {
      // Register route provider
      final routeProvider = CustomerAppRoutes();
      appRouter.addRoutes(routeProvider.routes);
      _routesInitialized = true;
      debugPrint('Routes registered');
    }
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final appTheme = getIt<AppTheme>();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Food Delivery',
        theme: appTheme.lightTheme,
        darkTheme: appTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.router,
        localizationsDelegates: const [
          ...localizationDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ErrorBoundary(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// Temporary home screen for testing the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate to login when user becomes unauthenticated
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('home'.tr(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Add logout event to the AuthBloc
                context.read<AuthBloc>().add(SignOut());
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logging out...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                
                // The redirect middleware will handle navigation
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'app_name'.tr(context),
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Log a test event
                  getIt<AnalyticsService>().logScreenView(
                    screenName: 'home_screen',
                    screenClass: 'HomeScreen',
                  );
                  
                  // Show a test message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('loading'.tr(context)),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: Text('ok'.tr(context)),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Column(
                      children: [
                        Text('Logged in as: ${state.user.email}'),
                        Text('Role: ${state.role}'),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
