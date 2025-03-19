import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/route_data.dart';
import 'package:live_tracking_module/services/mapbox_service.dart';
import 'package:injectable/injectable.dart';

/// Interface for accessing map-related functionality
abstract class MapRepository {
  /// Get a route between two points
  Future<RouteData> getRoute(LocationUpdate origin, LocationUpdate destination);
  
  /// Get ETA between two points
  Future<int> getEstimatedTimeOfArrival(LocationUpdate origin, LocationUpdate destination);
  
  /// Get the Mapbox access token for rendering maps
  String getMapboxAccessToken();
}

/// Implementation of MapRepository using Mapbox
@Injectable(as: MapRepository)
class MapboxMapRepository implements MapRepository {
  final MapboxService _mapboxService;
  
  MapboxMapRepository(this._mapboxService);
  
  @override
  Future<RouteData> getRoute(LocationUpdate origin, LocationUpdate destination) async {
    try {
      return await _mapboxService.getDirections(
        originLatitude: origin.latitude,
        originLongitude: origin.longitude,
        destinationLatitude: destination.latitude,
        destinationLongitude: destination.longitude,
      );
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }
  
  @override
  Future<int> getEstimatedTimeOfArrival(LocationUpdate origin, LocationUpdate destination) async {
    try {
      final route = await getRoute(origin, destination);
      return (route.durationInSeconds / 60).ceil(); // Convert seconds to minutes
    } catch (e) {
      throw Exception('Failed to get ETA: $e');
    }
  }
  
  @override
  String getMapboxAccessToken() {
    return _mapboxService.getAccessToken();
  }
} 