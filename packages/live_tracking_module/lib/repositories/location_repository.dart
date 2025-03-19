import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/tracking_data.dart';
import 'package:uuid/uuid.dart';

/// Interface for accessing location-related functionality
abstract class LocationRepository {
  /// Listen for real-time location updates for a specific entity
  Stream<LocationUpdate> listenForLocationUpdates(String entityType, String entityId);
  
  /// Listen for tracking data updates for a specific order
  Stream<TrackingData> listenForTrackingUpdates(String orderId);
  
  /// Send a location update
  Future<void> sendLocationUpdate(LocationUpdate locationUpdate);
  
  /// Update tracking status
  Future<void> updateTrackingStatus(String orderId, TrackingStatus status);
  
  /// Get tracking data for an order
  Future<TrackingData?> getTrackingData(String orderId);
  
  /// Initialize tracking for an order
  Future<TrackingData> initializeTracking(
    String orderId,
    LocationUpdate restaurantLocation,
    LocationUpdate customerLocation,
  );
}

/// Implementation of LocationRepository using Firebase
@Injectable(as: LocationRepository)
class FirebaseLocationRepository implements LocationRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();
  
  FirebaseLocationRepository() : _firestore = FirebaseFirestore.instance;
  
  @override
  Stream<LocationUpdate> listenForLocationUpdates(String entityType, String entityId) {
    return _firestore
        .collection('location_updates')
        .where('entityType', isEqualTo: entityType)
        .where('entityId', isEqualTo: entityId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            throw Exception('No location updates found');
          }
          return LocationUpdate.fromJson(snapshot.docs.first.data());
        });
  }
  
  @override
  Stream<TrackingData> listenForTrackingUpdates(String orderId) {
    return _firestore
        .collection('tracking')
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            throw Exception('No tracking data found for order $orderId');
          }
          return TrackingData.fromJson(snapshot.docs.first.data());
        });
  }
  
  @override
  Future<void> sendLocationUpdate(LocationUpdate locationUpdate) async {
    await _firestore
        .collection('location_updates')
        .doc(locationUpdate.id)
        .set(locationUpdate.toJson());
    
    // If this is a driver update, also update the tracking data
    if (locationUpdate.entityType == 'driver') {
      // Find orders assigned to this driver
      final orderQuery = await _firestore
          .collection('orders')
          .where('driverId', isEqualTo: locationUpdate.entityId)
          .where('status', whereIn: [
            'assigned_to_driver',
            'picked_up',
            'on_the_way'
          ])
          .get();
      
      // Update tracking data for each order
      for (final orderDoc in orderQuery.docs) {
        final orderId = orderDoc.id;
        
        final trackingQuery = await _firestore
            .collection('tracking')
            .where('orderId', isEqualTo: orderId)
            .get();
        
        if (trackingQuery.docs.isNotEmpty) {
          final trackingData = TrackingData.fromJson(trackingQuery.docs.first.data());
          
          await _firestore
              .collection('tracking')
              .doc(trackingQuery.docs.first.id)
              .update({
                'driverLocation': locationUpdate.toJson(),
                'lastUpdated': DateTime.now().millisecondsSinceEpoch,
              });
        }
      }
    }
  }
  
  @override
  Future<void> updateTrackingStatus(String orderId, TrackingStatus status) async {
    final trackingQuery = await _firestore
        .collection('tracking')
        .where('orderId', isEqualTo: orderId)
        .get();
    
    if (trackingQuery.docs.isNotEmpty) {
      await _firestore
          .collection('tracking')
          .doc(trackingQuery.docs.first.id)
          .update({
            'status': status.toString(),
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          });
    }
  }
  
  @override
  Future<TrackingData?> getTrackingData(String orderId) async {
    final trackingQuery = await _firestore
        .collection('tracking')
        .where('orderId', isEqualTo: orderId)
        .get();
    
    if (trackingQuery.docs.isEmpty) {
      return null;
    }
    
    return TrackingData.fromJson(trackingQuery.docs.first.data());
  }
  
  @override
  Future<TrackingData> initializeTracking(
    String orderId,
    LocationUpdate restaurantLocation,
    LocationUpdate customerLocation,
  ) async {
    // Check if tracking already exists
    final existingTracking = await getTrackingData(orderId);
    if (existingTracking != null) {
      return existingTracking;
    }
    
    // Create new tracking
    final now = DateTime.now();
    final trackingData = TrackingData(
      id: _uuid.v4(),
      orderId: orderId,
      restaurantLocation: restaurantLocation,
      customerLocation: customerLocation,
      status: TrackingStatus.orderPlaced,
      startTime: now,
      lastUpdated: now,
    );
    
    // Save to Firestore
    await _firestore
        .collection('tracking')
        .doc(trackingData.id)
        .set(trackingData.toJson());
    
    return trackingData;
  }
} 