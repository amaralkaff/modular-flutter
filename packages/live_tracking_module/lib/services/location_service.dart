import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:uuid/uuid.dart';

/// Service for handling device location
@injectable
class LocationService {
  final _uuid = const Uuid();
  
  /// Stream of location updates from the device
  StreamController<LocationUpdate>? _locationStreamController;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  /// Get the current position of the device
  Future<Position> getCurrentPosition() async {
    final permission = await _checkPermission();
    
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      throw Exception('Failed to get current position: $e');
    }
  }
  
  /// Check and request location permission
  Future<LocationPermission> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }
  
  /// Start listening for location updates
  Stream<LocationUpdate> startLocationUpdates({
    required String entityType,
    required String entityId,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int intervalInSeconds = 5,
  }) {
    // Close any existing stream
    stopLocationUpdates();
    
    _locationStreamController = StreamController<LocationUpdate>.broadcast();
    
    _checkPermission().then((permission) {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationStreamController?.addError(Exception('Location permission denied'));
        return;
      }
      
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: accuracy,
          intervalDuration: Duration(seconds: intervalInSeconds),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Location Tracking',
            notificationText: 'Sharing your location for order tracking',
            enableWakeLock: true,
          ),
        ),
      ).listen(
        (Position position) {
          final locationUpdate = LocationUpdate(
            id: _uuid.v4(),
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
            speed: position.speed,
            accuracy: position.accuracy,
            timestamp: DateTime.now(),
            entityType: entityType,
            entityId: entityId,
          );
          
          _locationStreamController?.add(locationUpdate);
        },
        onError: (error) {
          debugPrint('Error in location stream: $error');
          _locationStreamController?.addError(error);
        },
      );
    }).catchError((error) {
      debugPrint('Error checking permission: $error');
      _locationStreamController?.addError(error);
    });
    
    return _locationStreamController!.stream;
  }
  
  /// Stop listening for location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    _locationStreamController?.close();
    _locationStreamController = null;
  }
  
  /// Convert a Position to a LocationUpdate
  LocationUpdate positionToLocationUpdate(
    Position position, {
    required String entityType,
    required String entityId,
  }) {
    return LocationUpdate(
      id: _uuid.v4(),
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
      speed: position.speed,
      accuracy: position.accuracy,
      timestamp: DateTime.now(),
      entityType: entityType,
      entityId: entityId,
    );
  }
} 