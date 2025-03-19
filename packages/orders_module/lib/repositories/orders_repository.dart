import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orders_module/models/order_model.dart' as order_model;

abstract class OrdersRepository {
  /// Get a stream of orders for a specific customer
  Stream<List<order_model.Order>> getCustomerOrders(String customerId);
  
  /// Get a stream of orders for a specific driver
  Stream<List<order_model.Order>> getDriverOrders(String driverId);
  
  /// Get a stream of orders for a specific restaurant
  Stream<List<order_model.Order>> getRestaurantOrders(String restaurantId);
  
  /// Get a specific order by ID with real-time updates
  Stream<order_model.Order> getOrderById(String orderId);
  
  /// Create a new order in the database
  Future<String> createOrder(order_model.Order order);
  
  /// Update an existing order's status
  Future<void> updateOrderStatus(String orderId, order_model.OrderStatus status);
  
  /// Assign a driver to an order
  Future<void> assignDriver(String orderId, String driverId);
  
  /// Update an order's estimated delivery time
  Future<void> updateEstimatedDeliveryTime(String orderId, DateTime estimatedTime);
  
  /// Mark an order as delivered
  Future<void> markOrderAsDelivered(String orderId);
  
  /// Cancel an order with a reason
  Future<void> cancelOrder(String orderId, String reason);
}

class FirebaseOrdersRepository implements OrdersRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'orders';

  FirebaseOrdersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<order_model.Order>> getCustomerOrders(String customerId) {
    return _firestore
        .collection(_collectionPath)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => order_model.Order.fromJson(doc.data())).toList());
  }

  @override
  Stream<List<order_model.Order>> getDriverOrders(String driverId) {
    return _firestore
        .collection(_collectionPath)
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [
          order_model.OrderStatus.readyForPickup.name,
          order_model.OrderStatus.pickedUp.name,
          order_model.OrderStatus.inDelivery.name
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => order_model.Order.fromJson(doc.data())).toList());
  }

  @override
  Stream<List<order_model.Order>> getRestaurantOrders(String restaurantId) {
    return _firestore
        .collection(_collectionPath)
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', whereIn: [
          order_model.OrderStatus.pending.name,
          order_model.OrderStatus.preparing.name,
          order_model.OrderStatus.readyForPickup.name
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => order_model.Order.fromJson(doc.data())).toList());
  }

  @override
  Stream<order_model.Order> getOrderById(String orderId) {
    return _firestore
        .collection(_collectionPath)
        .doc(orderId)
        .snapshots()
        .map((snapshot) => order_model.Order.fromJson(snapshot.data()!));
  }

  @override
  Future<String> createOrder(order_model.Order order) async {
    final docRef = _firestore.collection(_collectionPath).doc(order.id);
    await docRef.set(order.toJson());
    return order.id;
  }

  @override
  Future<void> updateOrderStatus(String orderId, order_model.OrderStatus status) async {
    await _firestore
        .collection(_collectionPath)
        .doc(orderId)
        .update({'status': status.name});
  }

  @override
  Future<void> assignDriver(String orderId, String driverId) async {
    await _firestore
        .collection(_collectionPath)
        .doc(orderId)
        .update({'driverId': driverId, 'status': order_model.OrderStatus.pickedUp.name});
  }

  @override
  Future<void> updateEstimatedDeliveryTime(
      String orderId, DateTime estimatedTime) async {
    await _firestore.collection(_collectionPath).doc(orderId).update(
        {'estimatedDeliveryTime': Timestamp.fromDate(estimatedTime)});
  }

  @override
  Future<void> markOrderAsDelivered(String orderId) async {
    await _firestore.collection(_collectionPath).doc(orderId).update({
      'status': order_model.OrderStatus.delivered.name,
      'actualDeliveryTime': Timestamp.fromDate(DateTime.now())
    });
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    await _firestore.collection(_collectionPath).doc(orderId).update({
      'status': order_model.OrderStatus.cancelled.name,
      'cancellationReason': reason,
    });
  }
} 