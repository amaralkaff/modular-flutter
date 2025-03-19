import 'package:core_module/core_module.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/screens/login_screen.dart';
import 'package:auth/presentation/screens/register_screen.dart';
import 'package:auth/presentation/screens/reset_password_screen.dart';

import 'main.dart';
import 'screens/splash_screen.dart';

/// Routes for the customer app
class CustomerAppRoutes implements RouteProvider {
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ];
} 