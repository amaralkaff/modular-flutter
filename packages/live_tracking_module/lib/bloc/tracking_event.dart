import 'package:equatable/equatable.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/tracking_data.dart';

/// Base class for all tracking events
abstract class TrackingEvent extends Equatable {
  const TrackingEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to initialize tracking for an order
class InitializeTrackingEvent extends TrackingEvent {
  final String orderId;
  final LocationUpdate restaurantLocation;
  final LocationUpdate customerLocation;
  
  const InitializeTrackingEvent({
    required this.orderId,
    required this.restaurantLocation,
    required this.customerLocation,
  });
  
  @override
  List<Object?> get props => [orderId, restaurantLocation, customerLocation];
}

/// Event to start listening for tracking updates
class StartTrackingListenEvent extends TrackingEvent {
  final String orderId;
  
  const StartTrackingListenEvent(this.orderId);
  
  @override
  List<Object?> get props => [orderId];
}

/// Event to stop listening for tracking updates
class StopTrackingListenEvent extends TrackingEvent {}

/// Event to update driver location
class UpdateDriverLocationEvent extends TrackingEvent {
  final LocationUpdate locationUpdate;
  
  const UpdateDriverLocationEvent(this.locationUpdate);
  
  @override
  List<Object?> get props => [locationUpdate];
}

/// Event to update tracking status
class UpdateTrackingStatusEvent extends TrackingEvent {
  final String orderId;
  final TrackingStatus status;
  
  const UpdateTrackingStatusEvent({
    required this.orderId,
    required this.status,
  });
  
  @override
  List<Object?> get props => [orderId, status];
}

/// Event when tracking data is received from stream
class TrackingDataReceivedEvent extends TrackingEvent {
  final TrackingData trackingData;
  
  const TrackingDataReceivedEvent(this.trackingData);
  
  @override
  List<Object?> get props => [trackingData];
}

/// Event to calculate route
class CalculateRouteEvent extends TrackingEvent {
  final LocationUpdate origin;
  final LocationUpdate destination;
  final String routeType; // 'driverToRestaurant', 'driverToCustomer', 'restaurantToCustomer'
  
  const CalculateRouteEvent({
    required this.origin,
    required this.destination,
    required this.routeType,
  });
  
  @override
  List<Object?> get props => [origin, destination, routeType];
}

/// Event to center map on specific location
class CenterMapEvent extends TrackingEvent {
  final LocationUpdate location;
  
  const CenterMapEvent(this.location);
  
  @override
  List<Object?> get props => [location];
}

/// Event when an error occurs
class TrackingErrorEvent extends TrackingEvent {
  final String message;
  
  const TrackingErrorEvent(this.message);
  
  @override
  List<Object?> get props => [message];
} 