import 'package:equatable/equatable.dart';

/// Represents a route between two points with directions and ETA
class RouteData extends Equatable {
  /// Unique identifier for this route
  final String id;
  
  /// List of points (coordinates) that define the route
  final List<RoutePoint> points;
  
  /// Total distance of the route in meters
  final double distanceInMeters;
  
  /// Estimated duration of the route in seconds
  final int durationInSeconds;
  
  /// List of instructions for navigation
  final List<RouteInstruction> instructions;
  
  /// Timestamp when the route was calculated/updated
  final DateTime timestamp;
  
  const RouteData({
    required this.id,
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
    required this.instructions,
    required this.timestamp,
  });
  
  /// Convert from JSON map
  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      id: json['id'] as String,
      points: (json['points'] as List<dynamic>)
          .map((point) => RoutePoint.fromJson(point as Map<String, dynamic>))
          .toList(),
      distanceInMeters: json['distanceInMeters'] as double,
      durationInSeconds: json['durationInSeconds'] as int,
      instructions: (json['instructions'] as List<dynamic>)
          .map((instruction) => RouteInstruction.fromJson(instruction as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((point) => point.toJson()).toList(),
      'distanceInMeters': distanceInMeters,
      'durationInSeconds': durationInSeconds,
      'instructions': instructions.map((instruction) => instruction.toJson()).toList(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    points,
    distanceInMeters,
    durationInSeconds,
    instructions,
    timestamp,
  ];
  
  /// Get the formatted distance string
  String get formattedDistance {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} m';
    } else {
      final kilometers = distanceInMeters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }
  
  /// Get the formatted duration string
  String get formattedDuration {
    final minutes = (durationInSeconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }
}

/// Represents a single point on a route
class RoutePoint extends Equatable {
  /// The latitude coordinate
  final double latitude;
  
  /// The longitude coordinate
  final double longitude;
  
  const RoutePoint({
    required this.latitude,
    required this.longitude,
  });
  
  /// Convert from JSON map
  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  @override
  List<Object?> get props => [latitude, longitude];
}

/// Represents a navigation instruction for a route
class RouteInstruction extends Equatable {
  /// Distance from the start of the route to this instruction in meters
  final double distanceFromStart;
  
  /// Instruction text (e.g., "Turn right onto Main Street")
  final String text;
  
  /// Type of maneuver (e.g., turn, straight, etc.)
  final String maneuverType;
  
  /// Index of the point in the route where this instruction applies
  final int pointIndex;
  
  const RouteInstruction({
    required this.distanceFromStart,
    required this.text,
    required this.maneuverType,
    required this.pointIndex,
  });
  
  /// Convert from JSON map
  factory RouteInstruction.fromJson(Map<String, dynamic> json) {
    return RouteInstruction(
      distanceFromStart: json['distanceFromStart'] as double,
      text: json['text'] as String,
      maneuverType: json['maneuverType'] as String,
      pointIndex: json['pointIndex'] as int,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'distanceFromStart': distanceFromStart,
      'text': text,
      'maneuverType': maneuverType,
      'pointIndex': pointIndex,
    };
  }
  
  @override
  List<Object?> get props => [
    distanceFromStart,
    text,
    maneuverType,
    pointIndex,
  ];
} 