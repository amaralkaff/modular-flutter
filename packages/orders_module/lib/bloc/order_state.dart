import 'package:equatable/equatable.dart';
import 'package:orders_module/models/order_model.dart' as order_model;

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrdersLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<order_model.Order> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoading extends OrderState {}

class OrderDetailsLoaded extends OrderState {
  final order_model.Order order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final String orderId;

  const OrderCreated(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderUpdating extends OrderState {}

class OrderUpdated extends OrderState {}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
} 