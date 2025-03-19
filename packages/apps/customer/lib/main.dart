import 'package:core_module/core_module.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'utils/env_loader.dart';
import 'utils/app_dependencies.dart';

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

/// Initialize Mapbox with proper error handling
Future<void> initializeMapbox() async {
  try {
    // Get access token from environment
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('WARNING: Mapbox access token not found in environment');
      return;
    }
    
    // Set the global access token for Mapbox
    MapboxOptions.setAccessToken(accessToken);
    debugPrint('Mapbox initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Error initializing Mapbox: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables first
    await loadEnvironmentVariables();
    
    // Initialize Firebase with proper error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      // Check if the error is related to Firebase configuration
      if (e.toString().contains('api-key') || 
          e.toString().contains('placeholder') ||
          e.toString().contains('configuration')) {
        // Show a more helpful error for configuration issues
        runApp(MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase Configuration Error',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The Firebase configuration in firebase_options.dart contains placeholder values.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please generate proper Firebase configuration using the FlutterFire CLI:',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('dart pub global activate flutterfire_cli'),
                          SizedBox(height: 8),
                          Text('flutterfire configure'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
        return; // Stop execution here
      }
      
      // If Firebase fails to initialize for other reasons, log the error but continue
      debugPrint('Firebase initialization issue: $e');
      // We can continue without Firebase in some cases
    }
    
    // Initialize Mapbox
    await initializeMapbox();
    
    // Setup error reporting if Firebase Crashlytics is available
    try {
      FlutterError.onError = (details) {
        debugPrint('Flutter error: ${details.exception}');
        try {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        } catch (e) {
          // Crashlytics might not be available
          debugPrint('Error reporting to Crashlytics: $e');
        }
      };
    } catch (e) {
      debugPrint('Error setting up error reporting: $e');
    }
    
    // Register all modules
    await setupAppDependencies();
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Log the error
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Still run the app, but in a safer mode
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App initialization error. Please restart the app.'),
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
              ElevatedButton(
                onPressed: () {
                  // Navigate to restaurants list
                  context.go('/restaurants');
                },
                child: Text('Browse Restaurants'),
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
