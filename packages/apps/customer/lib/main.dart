import 'package:core_module/core_module.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  final firebaseService = await FirebaseService.init();
  
  // Initialize local storage
  final storageService = await LocalStorageService.init();
  
  // Initialize dependency injection
  await configureDependencies(environment: Env.dev);
  
  // Register services in GetIt
  getIt.registerSingleton<FirebaseService>(firebaseService);
  getIt.registerSingleton<LocalStorageService>(storageService);
  getIt.registerSingleton<FirebaseAnalytics>(firebaseService.analytics);
  getIt.registerSingleton<AnalyticsService>(AnalyticsService(firebaseService.analytics));
  getIt.registerSingleton<AppLogger>(AppLogger(crashlytics: firebaseService.crashlytics));
  
  // Configure error handling
  firebaseService.configureErrorHandling(getIt<AppLogger>());
  
  // Initialize app router
  final appRouter = getIt<AppRouter>();
  
  // Register route provider
  final routeProvider = CustomerAppRoutes();
  appRouter.addRoutes(routeProvider.routes);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final appTheme = getIt<AppTheme>();
    
    return MaterialApp.router(
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
    );
  }
}

// Temporary home screen for testing the app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr(context)),
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
          ],
        ),
      ),
    );
  }
}
