
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:live_tracking_module/models/route_data.dart';
import 'package:uuid/uuid.dart';

/// Service for interacting with Mapbox APIs
@injectable
class MapboxService {
  final Dio _dio;
  final _uuid = const Uuid();
  
  // Load token from environment variables
  final String _accessToken;
  
  MapboxService() : 
    _dio = Dio(),
    _accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '' {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );
    
    if (_accessToken.isEmpty) {
      debugPrint('WARNING: Mapbox access token is empty. Please set MAPBOX_ACCESS_TOKEN in .env file');
    }
  }
  
  /// Get the Mapbox access token
  String getAccessToken() {
    return _accessToken;
  }
  
  /// Get directions between two points using Mapbox Directions API
  Future<RouteData> getDirections({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    try {
      final originCoords = '$originLongitude,$originLatitude';
      final destCoords = '$destinationLongitude,$destinationLatitude';
      
      final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$originCoords;$destCoords';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': true,
          'annotations': 'distance,duration',
        },
      );
      
      if (response.statusCode == 200) {
        return _parseRouteResponse(response.data);
      } else {
        throw Exception('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      throw Exception('Failed to get directions: $e');
    }
  }
  
  /// Parse the Mapbox Directions API response
  RouteData _parseRouteResponse(Map<String, dynamic> responseData) {
    try {
      final routes = responseData['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        throw Exception('No routes found');
      }
      
      final route = routes[0] as Map<String, dynamic>;
      final distance = route['distance'] as double;
      final duration = (route['duration'] as double).toInt();
      
      // Parse the geometry
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      
      // Create route points from coordinates
      final List<RoutePoint> points = coordinates.map((coord) {
        final List<dynamic> latLng = coord as List<dynamic>;
        // Note: Mapbox returns coordinates as [longitude, latitude]
        return RoutePoint(
          latitude: latLng[1] as double,
          longitude: latLng[0] as double,
        );
      }).toList();
      
      // Parse the legs for instructions
      final legs = route['legs'] as List<dynamic>;
      final List<RouteInstruction> instructions = [];
      
      double distanceFromStart = 0.0;
      int currentPointIndex = 0;
      
      for (final leg in legs) {
        final steps = leg['steps'] as List<dynamic>;
        
        for (final step in steps) {
          final maneuver = step['maneuver'] as Map<String, dynamic>;
          final instruction = step['instruction'] as String;
          final stepDistance = step['distance'] as double;
          
          instructions.add(RouteInstruction(
            distanceFromStart: distanceFromStart,
            text: instruction,
            maneuverType: maneuver['type'] as String,
            pointIndex: currentPointIndex,
          ));
          
          distanceFromStart += stepDistance;
          currentPointIndex += (step['geometry']['coordinates'] as List<dynamic>).length;
        }
      }
      
      return RouteData(
        id: _uuid.v4(),
        points: points,
        distanceInMeters: distance,
        durationInSeconds: duration,
        instructions: instructions,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing route response: $e');
      throw Exception('Failed to parse route data: $e');
    }
  }
  
  /// Reverse geocode coordinates to get an address
  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _accessToken,
          'limit': 1,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>;
        
        if (features.isNotEmpty) {
          final feature = features[0] as Map<String, dynamic>;
          return feature['place_name'] as String;
        } else {
          return 'Unknown location';
        }
      } else {
        throw Exception('Failed to reverse geocode: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return 'Unknown location';
    }
  }
} 