import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';

/// Splash screen shown when the app starts
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    
    // Start a timer to navigate to the next screen
    _timer = Timer(const Duration(seconds: 2), () {
      _navigateToNextScreen();
    });

    // Log the screen view
    getIt<AnalyticsService>().logScreenView(
      screenName: 'splash_screen',
      screenClass: 'SplashScreen',
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToNextScreen() {
    final isLoggedIn = getIt<LocalStorageService>().isLoggedIn();
    
    if (isLoggedIn) {
      // Navigate to home screen
      getIt<AppRouter>().router.goNamed('home');
    } else {
      // Navigate to home screen for now, in the future will navigate to login/onboarding
      getIt<AppRouter>().router.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo (using a placeholder)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'app_name'.tr(context),
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 