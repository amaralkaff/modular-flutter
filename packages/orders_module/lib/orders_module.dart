library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Internal imports
import 'package:orders_module/bloc/order_bloc.dart';
import 'package:orders_module/bloc/order_event.dart';
import 'package:orders_module/bloc/order_state.dart';
import 'package:orders_module/models/order_model.dart' as order_model;
import 'package:orders_module/repositories/orders_repository.dart';
import 'package:orders_module/screens/order_confirmation_screen.dart';
import 'package:orders_module/screens/order_history_screen.dart';
import 'package:orders_module/screens/order_tracking_screen.dart';

// Export models
export 'package:orders_module/models/order_model.dart';

// Export repositories
export 'package:orders_module/repositories/orders_repository.dart';

// Export bloc
export 'package:orders_module/bloc/order_bloc.dart';
export 'package:orders_module/bloc/order_event.dart';
export 'package:orders_module/bloc/order_state.dart';

// Export screens
export 'package:orders_module/screens/order_confirmation_screen.dart';
export 'package:orders_module/screens/order_history_screen.dart';
export 'package:orders_module/screens/order_tracking_screen.dart';

/// Sets up the Orders Module by registering dependencies
void setupOrdersModule() {
  final getIt = GetIt.instance;
  
  // Register repositories
  if (!getIt.isRegistered<OrdersRepository>()) {
    getIt.registerLazySingleton<OrdersRepository>(
      () => FirebaseOrdersRepository(),
    );
  }
  
  // Register blocs
  if (!getIt.isRegistered<OrderBloc>()) {
    getIt.registerFactory<OrderBloc>(
      () => OrderBloc(ordersRepository: getIt<OrdersRepository>()),
    );
  }
}

/// Provider widget for OrderBloc
class OrdersModuleProvider extends StatelessWidget {
  final Widget child;
  
  const OrdersModuleProvider({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrderBloc>(),
      child: child,
    );
  }
}

/// Navigation extension methods for Orders Module
extension OrdersModuleNavigation on BuildContext {
  /// Navigate to order confirmation screen
  Future<void> navigateToOrderConfirmation(String orderId) {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(orderId: orderId),
      ),
    );
  }
  
  /// Navigate to order tracking screen
  Future<void> navigateToOrderTracking(String orderId) {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: orderId),
      ),
    );
  }
  
  /// Navigate to order history screen
  Future<void> navigateToOrderHistory(String userId, {bool isCustomer = true}) {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(
          userId: userId, 
          isCustomer: isCustomer,
        ),
      ),
    );
  }
} 