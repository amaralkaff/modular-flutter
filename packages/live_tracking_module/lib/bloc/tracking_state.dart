import 'package:equatable/equatable.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/tracking_data.dart';

/// Base class for all tracking states
abstract class TrackingState extends Equatable {
  const TrackingState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class TrackingInitial extends TrackingState {}

/// Loading state
class TrackingLoading extends TrackingState {}

/// State when tracking is active and data is available
class TrackingActive extends TrackingState {
  final TrackingData trackingData;
  final LocationUpdate? centeredLocation;
  
  const TrackingActive(this.trackingData, {this.centeredLocation});
  
  @override
  List<Object?> get props => [trackingData, centeredLocation];
  
  TrackingActive copyWith({
    TrackingData? trackingData,
    LocationUpdate? centeredLocation,
  }) {
    return TrackingActive(
      trackingData ?? this.trackingData,
      centeredLocation: centeredLocation ?? this.centeredLocation,
    );
  }
}

/// State when route calculation is in progress
class RouteCalculating extends TrackingState {
  final TrackingData trackingData;
  final String routeType;
  
  const RouteCalculating(this.trackingData, this.routeType);
  
  @override
  List<Object?> get props => [trackingData, routeType];
}

/// State when a route has been calculated
class RouteCalculated extends TrackingState {
  final TrackingData trackingData;
  final String routeType;
  
  const RouteCalculated(this.trackingData, this.routeType);
  
  @override
  List<Object?> get props => [trackingData, routeType];
}

/// State when tracking has ended (delivery completed or canceled)
class TrackingEnded extends TrackingState {
  final TrackingData trackingData;
  
  const TrackingEnded(this.trackingData);
  
  @override
  List<Object?> get props => [trackingData];
}

/// Error state
class TrackingError extends TrackingState {
  final String message;
  final TrackingData? trackingData;
  
  const TrackingError(this.message, {this.trackingData});
  
  @override
  List<Object?> get props => [message, trackingData];
} 