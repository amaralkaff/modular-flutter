import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orders_module/bloc/order_event.dart';
import 'package:orders_module/bloc/order_state.dart';
import 'package:orders_module/models/order_model.dart' as order_model;
import 'package:orders_module/repositories/orders_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrdersRepository _ordersRepository;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _orderDetailsSubscription;

  OrderBloc({required OrdersRepository ordersRepository})
      : _ordersRepository = ordersRepository,
        super(OrderInitial()) {
    on<LoadCustomerOrders>(_onLoadCustomerOrders);
    on<LoadDriverOrders>(_onLoadDriverOrders);
    on<LoadRestaurantOrders>(_onLoadRestaurantOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<AssignDriverToOrder>(_onAssignDriverToOrder);
    on<UpdateDeliveryTime>(_onUpdateDeliveryTime);
    on<MarkOrderDelivered>(_onMarkOrderDelivered);
    on<CancelOrder>(_onCancelOrder);
    // Register internal stream handling events
    on<LoadCustomerOrdersSuccess>(_onLoadCustomerOrdersSuccess);
    on<LoadDriverOrdersSuccess>(_onLoadDriverOrdersSuccess);
    on<LoadRestaurantOrdersSuccess>(_onLoadRestaurantOrdersSuccess);
    on<LoadOrderDetailsSuccess>(_onLoadOrderDetailsSuccess);
  }

  Future<void> _onLoadCustomerOrders(
      LoadCustomerOrders event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    await _ordersSubscription?.cancel();
    
    try {
      _ordersSubscription = _ordersRepository
          .getCustomerOrders(event.customerId)
          .listen((orders) => add(LoadCustomerOrdersSuccess(orders)));
    } catch (e) {
      emit(OrderError('Failed to load customer orders: ${e.toString()}'));
    }
  }

  void _onLoadCustomerOrdersSuccess(
      LoadCustomerOrdersSuccess event, Emitter<OrderState> emit) {
    emit(OrdersLoaded(event.orders));
  }

  Future<void> _onLoadDriverOrders(
      LoadDriverOrders event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    await _ordersSubscription?.cancel();
    
    try {
      _ordersSubscription = _ordersRepository
          .getDriverOrders(event.driverId)
          .listen((orders) => add(LoadDriverOrdersSuccess(orders)));
    } catch (e) {
      emit(OrderError('Failed to load driver orders: ${e.toString()}'));
    }
  }

  void _onLoadDriverOrdersSuccess(
      LoadDriverOrdersSuccess event, Emitter<OrderState> emit) {
    emit(OrdersLoaded(event.orders));
  }

  Future<void> _onLoadRestaurantOrders(
      LoadRestaurantOrders event, Emitter<OrderState> emit) async {
    emit(OrdersLoading());
    await _ordersSubscription?.cancel();
    
    try {
      _ordersSubscription = _ordersRepository
          .getRestaurantOrders(event.restaurantId)
          .listen((orders) => add(LoadRestaurantOrdersSuccess(orders)));
    } catch (e) {
      emit(OrderError('Failed to load restaurant orders: ${e.toString()}'));
    }
  }

  void _onLoadRestaurantOrdersSuccess(
      LoadRestaurantOrdersSuccess event, Emitter<OrderState> emit) {
    emit(OrdersLoaded(event.orders));
  }

  Future<void> _onLoadOrderDetails(
      LoadOrderDetails event, Emitter<OrderState> emit) async {
    emit(OrderDetailsLoading());
    await _orderDetailsSubscription?.cancel();
    
    try {
      _orderDetailsSubscription = _ordersRepository
          .getOrderById(event.orderId)
          .listen((order) => add(LoadOrderDetailsSuccess(order)));
    } catch (e) {
      emit(OrderError('Failed to load order details: ${e.toString()}'));
    }
  }

  void _onLoadOrderDetailsSuccess(
      LoadOrderDetailsSuccess event, Emitter<OrderState> emit) {
    emit(OrderDetailsLoaded(event.order));
  }

  Future<void> _onCreateOrder(
      CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderCreating());
    
    try {
      final orderId = await _ordersRepository.createOrder(event.order);
      emit(OrderCreated(orderId));
    } catch (e) {
      emit(OrderError('Failed to create order: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrderState> emit) async {
    emit(OrderUpdating());
    
    try {
      await _ordersRepository.updateOrderStatus(event.orderId, event.status);
      emit(OrderUpdated());
    } catch (e) {
      emit(OrderError('Failed to update order status: ${e.toString()}'));
    }
  }

  Future<void> _onAssignDriverToOrder(
      AssignDriverToOrder event, Emitter<OrderState> emit) async {
    emit(OrderUpdating());
    
    try {
      await _ordersRepository.assignDriver(event.orderId, event.driverId);
      emit(OrderUpdated());
    } catch (e) {
      emit(OrderError('Failed to assign driver: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDeliveryTime(
      UpdateDeliveryTime event, Emitter<OrderState> emit) async {
    emit(OrderUpdating());
    
    try {
      await _ordersRepository.updateEstimatedDeliveryTime(
          event.orderId, event.estimatedTime);
      emit(OrderUpdated());
    } catch (e) {
      emit(OrderError('Failed to update delivery time: ${e.toString()}'));
    }
  }

  Future<void> _onMarkOrderDelivered(
      MarkOrderDelivered event, Emitter<OrderState> emit) async {
    emit(OrderUpdating());
    
    try {
      await _ordersRepository.markOrderAsDelivered(event.orderId);
      emit(OrderUpdated());
    } catch (e) {
      emit(OrderError('Failed to mark order as delivered: ${e.toString()}'));
    }
  }

  Future<void> _onCancelOrder(
      CancelOrder event, Emitter<OrderState> emit) async {
    emit(OrderUpdating());
    
    try {
      await _ordersRepository.cancelOrder(event.orderId, event.reason);
      emit(OrderCancelled());
    } catch (e) {
      emit(OrderError('Failed to cancel order: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _orderDetailsSubscription?.cancel();
    return super.close();
  }
}

// These are internal events for stream handling only
class LoadCustomerOrdersSuccess extends OrderEvent {
  final List<order_model.Order> orders;
  const LoadCustomerOrdersSuccess(this.orders);
  @override
  List<Object?> get props => [orders];
}

class LoadDriverOrdersSuccess extends OrderEvent {
  final List<order_model.Order> orders;
  const LoadDriverOrdersSuccess(this.orders);
  @override
  List<Object?> get props => [orders];
}

class LoadRestaurantOrdersSuccess extends OrderEvent {
  final List<order_model.Order> orders;
  const LoadRestaurantOrdersSuccess(this.orders);
  @override
  List<Object?> get props => [orders];
}

class LoadOrderDetailsSuccess extends OrderEvent {
  final order_model.Order order;
  const LoadOrderDetailsSuccess(this.order);
  @override
  List<Object?> get props => [order];
} 