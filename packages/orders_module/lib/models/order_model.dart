import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum OrderStatus {
  pending,
  preparing,
  readyForPickup,
  pickedUp,
  inDelivery,
  delivered,
  cancelled
}

extension OrderStatusX on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for pickup';
      case OrderStatus.pickedUp:
        return 'Picked up';
      case OrderStatus.inDelivery:
        return 'In delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final Map<String, dynamic>? customizations;

  OrderItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.customizations,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      customizations: json['customizations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'customizations': customizations,
    };
  }
}

class Order extends Equatable {
  final String id;
  final String customerId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String deliveryAddress;
  final OrderStatus status;
  final String? driverId;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String? cancellationReason;
  final String? notes;
  final String? paymentMethodId;
  final bool isPaid;

  Order({
    String? id,
    required this.customerId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.deliveryAddress,
    this.status = OrderStatus.pending,
    this.driverId,
    DateTime? createdAt,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.cancellationReason,
    this.notes,
    this.paymentMethodId,
    this.isPaid = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        customerId,
        restaurantId,
        items,
        status,
        createdAt,
      ];

  Order copyWith({
    String? id,
    String? customerId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? total,
    String? deliveryAddress,
    OrderStatus? status,
    String? driverId,
    DateTime? createdAt,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? cancellationReason,
    String? notes,
    String? paymentMethodId,
    bool? isPaid,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      deliveryAddress: json['deliveryAddress'],
      status: OrderStatus.values.byName(json['status']),
      driverId: json['driverId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? (json['estimatedDeliveryTime'] as Timestamp).toDate()
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? (json['actualDeliveryTime'] as Timestamp).toDate()
          : null,
      cancellationReason: json['cancellationReason'],
      notes: json['notes'],
      paymentMethodId: json['paymentMethodId'],
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'status': status.name,
      'driverId': driverId,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedDeliveryTime': estimatedDeliveryTime != null
          ? Timestamp.fromDate(estimatedDeliveryTime!)
          : null,
      'actualDeliveryTime': actualDeliveryTime != null
          ? Timestamp.fromDate(actualDeliveryTime!)
          : null,
      'cancellationReason': cancellationReason,
      'notes': notes,
      'paymentMethodId': paymentMethodId,
      'isPaid': isPaid,
    };
  }

  static double calculateSubtotal(List<OrderItem> items) {
    return items.fold(
        0, (previousValue, element) => previousValue + element.totalPrice);
  }
} 