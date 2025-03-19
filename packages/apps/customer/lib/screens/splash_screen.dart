import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth/auth.dart';

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
    // Check auth state from bloc instead of directly checking local storage
    final authState = context.read<AuthBloc>().state;
    
    if (authState is Authenticated) {
      // User is authenticated, navigate to home
      getIt<AppRouter>().router.goNamed('home');
    } else {
      // User is not authenticated, navigate to login
      getIt<AppRouter>().router.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // If auth state changes while on splash screen, handle navigation
          if (state is Authenticated) {
            getIt<AppRouter>().router.goNamed('home');
          } else if (state is Unauthenticated && _timer.isActive) {
            // Cancel timer and navigate immediately if we get a definitive auth state
            _timer.cancel();
            getIt<AppRouter>().router.goNamed('login');
          }
        },
        child: Center(
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
      ),
    );
  }
} 