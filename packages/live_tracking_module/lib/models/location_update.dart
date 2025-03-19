import 'package:equatable/equatable.dart';

/// Represents a location update from a driver or restaurant
class LocationUpdate extends Equatable {
  /// Unique identifier for this location update
  final String id;
  
  /// The latitude coordinate
  final double latitude;
  
  /// The longitude coordinate
  final double longitude;
  
  /// The heading in degrees (0-360, with 0 being North)
  final double? heading;
  
  /// Speed in meters per second
  final double? speed;
  
  /// Accuracy of the location in meters
  final double? accuracy;
  
  /// Timestamp when the location was recorded
  final DateTime timestamp;
  
  /// Type of the entity (driver, restaurant, customer)
  final String entityType;
  
  /// ID of the entity (driver ID, restaurant ID, etc.)
  final String entityId;
  
  const LocationUpdate({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
    required this.entityType,
    required this.entityId,
  });
  
  /// Convert from JSON map
  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      id: json['id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      heading: json['heading'] as double?,
      speed: json['speed'] as double?,
      accuracy: json['accuracy'] as double?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'entityType': entityType,
      'entityId': entityId,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    latitude,
    longitude,
    heading,
    speed,
    accuracy,
    timestamp,
    entityType,
    entityId,
  ];
} 