import 'package:equatable/equatable.dart';
import 'package:orders_module/models/order_model.dart' as order_model;

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerOrders extends OrderEvent {
  final String customerId;

  const LoadCustomerOrders(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadDriverOrders extends OrderEvent {
  final String driverId;

  const LoadDriverOrders(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class LoadRestaurantOrders extends OrderEvent {
  final String restaurantId;

  const LoadRestaurantOrders(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class LoadOrderDetails extends OrderEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CreateOrder extends OrderEvent {
  final order_model.Order order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final order_model.OrderStatus status;

  const UpdateOrderStatus(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class AssignDriverToOrder extends OrderEvent {
  final String orderId;
  final String driverId;

  const AssignDriverToOrder(this.orderId, this.driverId);

  @override
  List<Object?> get props => [orderId, driverId];
}

class UpdateDeliveryTime extends OrderEvent {
  final String orderId;
  final DateTime estimatedTime;

  const UpdateDeliveryTime(this.orderId, this.estimatedTime);

  @override
  List<Object?> get props => [orderId, estimatedTime];
}

class MarkOrderDelivered extends OrderEvent {
  final String orderId;

  const MarkOrderDelivered(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CancelOrder extends OrderEvent {
  final String orderId;
  final String reason;

  const CancelOrder(this.orderId, this.reason);

  @override
  List<Object?> get props => [orderId, reason];
} 