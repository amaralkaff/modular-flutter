import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:live_tracking_module/bloc/tracking_event.dart';
import 'package:live_tracking_module/bloc/tracking_state.dart';
import 'package:live_tracking_module/models/tracking_data.dart';
import 'package:live_tracking_module/repositories/location_repository.dart';
import 'package:live_tracking_module/repositories/map_repository.dart';

/// BLoC for managing live tracking state
@injectable
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final LocationRepository locationRepository;
  final MapRepository mapRepository;
  
  StreamSubscription? _trackingSubscription;
  String? _currentOrderId;
  
  TrackingBloc({
    required this.locationRepository,
    required this.mapRepository,
  }) : super(TrackingInitial()) {
    on<InitializeTrackingEvent>(_onInitializeTracking);
    on<StartTrackingListenEvent>(_onStartTrackingListen);
    on<StopTrackingListenEvent>(_onStopTrackingListen);
    on<TrackingDataReceivedEvent>(_onTrackingDataReceived);
    on<UpdateDriverLocationEvent>(_onUpdateDriverLocation);
    on<UpdateTrackingStatusEvent>(_onUpdateTrackingStatus);
    on<CalculateRouteEvent>(_onCalculateRoute);
    on<CenterMapEvent>(_onCenterMap);
    on<TrackingErrorEvent>(_onTrackingError);
  }
  
  Future<void> _onInitializeTracking(
    InitializeTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingLoading());
    
    try {
      final trackingData = await locationRepository.initializeTracking(
        event.orderId,
        event.restaurantLocation,
        event.customerLocation,
      );
      
      emit(TrackingActive(trackingData));
      
      // Calculate initial route
      add(CalculateRouteEvent(
        origin: trackingData.restaurantLocation,
        destination: trackingData.customerLocation,
        routeType: 'restaurantToCustomer',
      ));
      
      // Start listening for updates
      add(StartTrackingListenEvent(event.orderId));
    } catch (e) {
      emit(TrackingError('Failed to initialize tracking: $e'));
    }
  }
  
  Future<void> _onStartTrackingListen(
    StartTrackingListenEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // Cancel any existing subscription
    await _trackingSubscription?.cancel();
    
    _currentOrderId = event.orderId;
    
    try {
      _trackingSubscription = locationRepository
          .listenForTrackingUpdates(event.orderId)
          .listen(
        (trackingData) {
          add(TrackingDataReceivedEvent(trackingData));
        },
        onError: (error) {
          add(TrackingErrorEvent('Error listening for tracking updates: $error'));
        },
      );
    } catch (e) {
      emit(TrackingError('Failed to start tracking: $e'));
    }
  }
  
  Future<void> _onStopTrackingListen(
    StopTrackingListenEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _currentOrderId = null;
  }
  
  void _onTrackingDataReceived(
    TrackingDataReceivedEvent event,
    Emitter<TrackingState> emit,
  ) {
    if (state is TrackingActive) {
      final currentState = state as TrackingActive;
      emit(currentState.copyWith(trackingData: event.trackingData));
    } else {
      emit(TrackingActive(event.trackingData));
    }
    
    // If the status is delivered or canceled, end tracking
    if (event.trackingData.status == TrackingStatus.delivered ||
        event.trackingData.status == TrackingStatus.canceled) {
      emit(TrackingEnded(event.trackingData));
      add(StopTrackingListenEvent());
    }
  }
  
  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocationEvent event,
    Emitter<TrackingState> emit,
  ) async {
    try {
      await locationRepository.sendLocationUpdate(event.locationUpdate);
    } catch (e) {
      emit(TrackingError('Failed to update driver location: $e'));
    }
  }
  
  Future<void> _onUpdateTrackingStatus(
    UpdateTrackingStatusEvent event,
    Emitter<TrackingState> emit,
  ) async {
    try {
      await locationRepository.updateTrackingStatus(
        event.orderId,
        event.status,
      );
    } catch (e) {
      emit(TrackingError('Failed to update tracking status: $e'));
    }
  }
  
  Future<void> _onCalculateRoute(
    CalculateRouteEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingActive) {
      return;
    }
    
    final trackingData = (state as TrackingActive).trackingData;
    emit(RouteCalculating(trackingData, event.routeType));
    
    try {
      final route = await mapRepository.getRoute(
        event.origin,
        event.destination,
      );
      
      // Update tracking data with the new route
      TrackingData updatedTrackingData;
      
      switch (event.routeType) {
        case 'driverToRestaurant':
          updatedTrackingData = trackingData.copyWith(
            driverToRestaurantRoute: route,
          );
          break;
        case 'driverToCustomer':
          updatedTrackingData = trackingData.copyWith(
            driverToCustomerRoute: route,
          );
          break;
        case 'restaurantToCustomer':
          updatedTrackingData = trackingData.copyWith(
            restaurantToCustomerRoute: route,
          );
          break;
        default:
          throw Exception('Unknown route type: ${event.routeType}');
      }
      
      // Also update ETA
      final eta = (route.durationInSeconds / 60).ceil();
      updatedTrackingData = updatedTrackingData.copyWith(
        estimatedTimeOfArrival: eta,
      );
      
      emit(RouteCalculated(updatedTrackingData, event.routeType));
      emit(TrackingActive(updatedTrackingData));
    } catch (e) {
      emit(TrackingError('Failed to calculate route: $e', trackingData: trackingData));
      emit(TrackingActive(trackingData)); // Revert to active state
    }
  }
  
  void _onCenterMap(
    CenterMapEvent event,
    Emitter<TrackingState> emit,
  ) {
    if (state is TrackingActive) {
      final currentState = state as TrackingActive;
      emit(currentState.copyWith(centeredLocation: event.location));
    }
  }
  
  void _onTrackingError(
    TrackingErrorEvent event,
    Emitter<TrackingState> emit,
  ) {
    if (state is TrackingActive) {
      emit(TrackingError(
        event.message,
        trackingData: (state as TrackingActive).trackingData,
      ));
    } else {
      emit(TrackingError(event.message));
    }
  }
  
  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
} 