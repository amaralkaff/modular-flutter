import 'package:equatable/equatable.dart';
import 'location_update.dart';
import 'route_data.dart';

/// Represents tracking data for an order delivery
class TrackingData extends Equatable {
  /// Unique identifier for this tracking session
  final String id;
  
  /// Order ID associated with this tracking
  final String orderId;
  
  /// Location of the restaurant
  final LocationUpdate restaurantLocation;
  
  /// Location of the customer
  final LocationUpdate customerLocation;
  
  /// Current location of the driver (if available)
  final LocationUpdate? driverLocation;
  
  /// Route from restaurant to customer
  final RouteData? restaurantToCustomerRoute;
  
  /// Route from driver to restaurant (if driver is picking up)
  final RouteData? driverToRestaurantRoute;
  
  /// Route from driver to customer (if driver has picked up)
  final RouteData? driverToCustomerRoute;
  
  /// Estimated time of arrival (in minutes)
  final int? estimatedTimeOfArrival;
  
  /// Tracking status 
  final TrackingStatus status;
  
  /// Timestamp when the tracking started
  final DateTime startTime;
  
  /// Timestamp when the tracking was last updated
  final DateTime lastUpdated;
  
  const TrackingData({
    required this.id,
    required this.orderId,
    required this.restaurantLocation,
    required this.customerLocation,
    this.driverLocation,
    this.restaurantToCustomerRoute,
    this.driverToRestaurantRoute,
    this.driverToCustomerRoute,
    this.estimatedTimeOfArrival,
    required this.status,
    required this.startTime,
    required this.lastUpdated,
  });
  
  /// Convert from JSON map
  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      restaurantLocation: LocationUpdate.fromJson(
        json['restaurantLocation'] as Map<String, dynamic>,
      ),
      customerLocation: LocationUpdate.fromJson(
        json['customerLocation'] as Map<String, dynamic>,
      ),
      driverLocation: json['driverLocation'] != null
          ? LocationUpdate.fromJson(
              json['driverLocation'] as Map<String, dynamic>,
            )
          : null,
      restaurantToCustomerRoute: json['restaurantToCustomerRoute'] != null
          ? RouteData.fromJson(
              json['restaurantToCustomerRoute'] as Map<String, dynamic>,
            )
          : null,
      driverToRestaurantRoute: json['driverToRestaurantRoute'] != null
          ? RouteData.fromJson(
              json['driverToRestaurantRoute'] as Map<String, dynamic>,
            )
          : null,
      driverToCustomerRoute: json['driverToCustomerRoute'] != null
          ? RouteData.fromJson(
              json['driverToCustomerRoute'] as Map<String, dynamic>,
            )
          : null,
      estimatedTimeOfArrival: json['estimatedTimeOfArrival'] as int?,
      status: TrackingStatusExtension.fromString(json['status'] as String),
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'restaurantLocation': restaurantLocation.toJson(),
      'customerLocation': customerLocation.toJson(),
      'driverLocation': driverLocation?.toJson(),
      'restaurantToCustomerRoute': restaurantToCustomerRoute?.toJson(),
      'driverToRestaurantRoute': driverToRestaurantRoute?.toJson(),
      'driverToCustomerRoute': driverToCustomerRoute?.toJson(),
      'estimatedTimeOfArrival': estimatedTimeOfArrival,
      'status': status.toString(),
      'startTime': startTime.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    orderId,
    restaurantLocation,
    customerLocation,
    driverLocation,
    restaurantToCustomerRoute,
    driverToRestaurantRoute,
    driverToCustomerRoute,
    estimatedTimeOfArrival,
    status,
    startTime,
    lastUpdated,
  ];
  
  /// Create a copy of the tracking data with updated fields
  TrackingData copyWith({
    String? id,
    String? orderId,
    LocationUpdate? restaurantLocation,
    LocationUpdate? customerLocation,
    LocationUpdate? driverLocation,
    RouteData? restaurantToCustomerRoute,
    RouteData? driverToRestaurantRoute,
    RouteData? driverToCustomerRoute,
    int? estimatedTimeOfArrival,
    TrackingStatus? status,
    DateTime? startTime,
    DateTime? lastUpdated,
  }) {
    return TrackingData(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      customerLocation: customerLocation ?? this.customerLocation,
      driverLocation: driverLocation ?? this.driverLocation,
      restaurantToCustomerRoute: restaurantToCustomerRoute ?? this.restaurantToCustomerRoute,
      driverToRestaurantRoute: driverToRestaurantRoute ?? this.driverToRestaurantRoute,
      driverToCustomerRoute: driverToCustomerRoute ?? this.driverToCustomerRoute,
      estimatedTimeOfArrival: estimatedTimeOfArrival ?? this.estimatedTimeOfArrival,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Represents the current status of delivery tracking
enum TrackingStatus {
  /// Order has been placed but no tracking started
  orderPlaced,
  
  /// Driver is headed to the restaurant
  driverToRestaurant,
  
  /// Driver is at the restaurant picking up the order
  driverAtRestaurant,
  
  /// Driver is headed to the customer
  driverToCustomer,
  
  /// Driver has arrived at the customer's location
  driverAtCustomer,
  
  /// Order has been delivered
  delivered,
  
  /// Order has been canceled
  canceled,
}

/// Extension methods for TrackingStatus enum
extension TrackingStatusExtension on TrackingStatus {
  /// Convert the enum value to a human-readable string
  String get displayName {
    switch (this) {
      case TrackingStatus.orderPlaced:
        return 'Order Placed';
      case TrackingStatus.driverToRestaurant:
        return 'Driver to Restaurant';
      case TrackingStatus.driverAtRestaurant:
        return 'Driver at Restaurant';
      case TrackingStatus.driverToCustomer:
        return 'Driver to Customer';
      case TrackingStatus.driverAtCustomer:
        return 'Driver at Customer';
      case TrackingStatus.delivered:
        return 'Delivered';
      case TrackingStatus.canceled:
        return 'Canceled';
    }
  }
  
  /// Convert a string to a TrackingStatus enum
  static TrackingStatus fromString(String value) {
    switch (value) {
      case 'orderPlaced':
        return TrackingStatus.orderPlaced;
      case 'driverToRestaurant':
        return TrackingStatus.driverToRestaurant;
      case 'driverAtRestaurant':
        return TrackingStatus.driverAtRestaurant;
      case 'driverToCustomer':
        return TrackingStatus.driverToCustomer;
      case 'driverAtCustomer':
        return TrackingStatus.driverAtCustomer;
      case 'delivered':
        return TrackingStatus.delivered;
      case 'canceled':
        return TrackingStatus.canceled;
      default:
        return TrackingStatus.orderPlaced;
    }
  }
} 