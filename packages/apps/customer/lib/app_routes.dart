import 'package:core_module/core_module.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:auth/presentation/screens/login_screen.dart';
import 'package:auth/presentation/screens/register_screen.dart';
import 'package:auth/presentation/screens/reset_password_screen.dart';
import 'package:restaurant_catalog/presentation/screens/restaurant_list_screen.dart';
import 'package:restaurant_catalog/presentation/screens/restaurant_detail_screen.dart';
import 'package:restaurant_catalog/models/restaurant.dart';
import 'package:restaurant_catalog/domain/use_cases/get_restaurants_use_case.dart';
import 'package:restaurant_catalog/repositories/restaurant_repository.dart';
import 'package:get_it/get_it.dart';

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
    // Restaurant Catalog Routes
    GoRoute(
      path: '/restaurants',
      name: 'restaurants',
      builder: (context, state) => RestaurantListScreen(
        getRestaurantsUseCase: GetIt.instance<GetRestaurantsUseCase>(),
      ),
    ),
    GoRoute(
      path: '/restaurants/:id',
      name: 'restaurant-detail',
      builder: (context, state) {
        final restaurantId = state.pathParameters['id'] ?? '';
        final repository = GetIt.instance<RestaurantRepository>();
        
        return _RestaurantDetailScreenWrapper(
          restaurantId: restaurantId,
          repository: repository,
        );
      },
    ),
  ];
}

/// Wrapper widget to handle async loading of restaurant data
class _RestaurantDetailScreenWrapper extends StatefulWidget {
  final String restaurantId;
  final RestaurantRepository repository;

  const _RestaurantDetailScreenWrapper({
    required this.restaurantId,
    required this.repository,
  });

  @override
  State<_RestaurantDetailScreenWrapper> createState() => _RestaurantDetailScreenWrapperState();
}

class _RestaurantDetailScreenWrapperState extends State<_RestaurantDetailScreenWrapper> {
  late Future<Restaurant?> _restaurantFuture;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = widget.repository.getRestaurantById(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant?>(
      future: _restaurantFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return RestaurantDetailScreen(
            restaurant: snapshot.data!,
            repository: widget.repository,
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Restaurant Not Found'),
            ),
            body: const Center(
              child: Text('Restaurant not found'),
            ),
          );
        }
      },
    );
  }
} 