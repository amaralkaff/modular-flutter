import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/route_data.dart';

/// A reusable widget for displaying Mapbox maps
class CustomMapView extends StatefulWidget {
  /// The initial camera position
  final CameraOptions initialCameraPosition;
  
  /// The style string for the map
  final String styleUri;
  
  /// Whether the map is interactive (zoom, pan, etc.)
  final bool interactive;
  
  /// Whether to show the user's location
  final bool myLocationEnabled;
  
  /// Callback when the map is created
  final Function(MapboxMap)? onMapCreated;
  
  /// Callback when the map style is loaded
  final Function()? onStyleLoadedCallback;
  
  /// List of markers to show on the map
  final List<LocationMarker>? markers;
  
  /// List of routes to draw on the map
  final List<RouteDisplay>? routes;
  
  const CustomMapView({
    super.key,
    required this.initialCameraPosition,
    this.styleUri = MapboxStyles.MAPBOX_STREETS,
    this.interactive = true,
    this.myLocationEnabled = false,
    this.onMapCreated,
    this.onStyleLoadedCallback,
    this.markers,
    this.routes,
  });
  
  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  final List<PointAnnotation> _markerAnnotations = [];
  final List<PolylineAnnotation> _routeAnnotations = [];
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapWidget(
          key: const ValueKey("mapWidget"),
          styleUri: widget.styleUri,
          onMapCreated: _handleMapCreated,
        ),
        if (widget.interactive)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  onPressed: () => _zoom(1),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  onPressed: () => _zoom(-1),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  void _handleMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    
    // Set camera position
    mapboxMap.setCamera(widget.initialCameraPosition);
    
    // Setup location component if enabled
    if (widget.myLocationEnabled) {
      mapboxMap.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );
    }
    
    // Create annotation managers
    mapboxMap.annotations.createPointAnnotationManager().then((manager) {
      _pointAnnotationManager = manager;
      _addMarkersIfReady();
    });
    
    mapboxMap.annotations.createPolylineAnnotationManager().then((manager) {
      _polylineAnnotationManager = manager;
      _addRoutesIfReady();
    });
    
    if (widget.onMapCreated != null) {
      widget.onMapCreated!(mapboxMap);
    }
    
    // Call style loaded callback after a delay to ensure map is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.onStyleLoadedCallback != null) {
        widget.onStyleLoadedCallback!();
      }
    });
  }
  
  void _addMarkersIfReady() {
    if (_pointAnnotationManager != null && widget.markers != null) {
      for (final marker in widget.markers!) {
        _addMarker(marker);
      }
    }
  }
  
  void _addRoutesIfReady() {
    if (_polylineAnnotationManager != null && widget.routes != null) {
      for (final route in widget.routes!) {
        _addRoute(route);
      }
    }
  }
  
  Future<void> _addMarker(LocationMarker marker) async {
    if (_pointAnnotationManager == null) return;
    
    final options = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(
          marker.location.longitude,
          marker.location.latitude,
        ),
      ),
    );
    
    try {
      final annotation = await _pointAnnotationManager!.create(options);
      _markerAnnotations.add(annotation);
    } catch (e) {
      debugPrint('Error adding marker: $e');
    }
  }
  
  Future<void> _addRoute(RouteDisplay routeDisplay) async {
    if (_polylineAnnotationManager == null) return;
    
    final List<Position> points = routeDisplay.route.points.map((point) {
      return Position(point.longitude, point.latitude);
    }).toList();
    
    if (points.isEmpty) return;
    
    final options = PolylineAnnotationOptions(
      geometry: LineString(coordinates: points),
      lineColor: int.parse('0xFF${routeDisplay.colorHex.replaceAll('#', '')}'),
      lineWidth: routeDisplay.width,
      lineOpacity: routeDisplay.opacity,
    );
    
    try {
      final annotation = await _polylineAnnotationManager!.create(options);
      _routeAnnotations.add(annotation);
    } catch (e) {
      debugPrint('Error creating route: $e');
    }
  }
  
  void _zoom(int direction) {
    if (_mapboxMap == null) return;
    
    // Get current camera position
    _mapboxMap!.getCameraState().then((cameraState) {
      final currentZoom = cameraState.zoom;
      final newZoom = currentZoom + direction;
      
      // Create camera options with new zoom level
      final cameraOptions = CameraOptions(
        center: cameraState.center,
        zoom: newZoom,
      );
      
      // Animate to new zoom level
      _mapboxMap!.flyTo(
        cameraOptions,
        MapAnimationOptions(duration: 300),
      );
    });
  }
  
  void centerCamera(LocationUpdate location, {double zoom = 15.0}) {
    if (_mapboxMap == null) return;
    
    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(location.longitude, location.latitude)
      ),
      zoom: zoom,
    );
    
    _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 500));
  }
  
  void fitBounds(List<LocationUpdate> locations, {EdgeInsets padding = const EdgeInsets.all(50)}) {
    if (_mapboxMap == null || locations.isEmpty) return;
    
    // Calculate the bounds
    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;
    
    for (final location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }
    
    // Set camera to center of bounds
    _mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            (minLng + maxLng) / 2.0,
            (minLat + maxLat) / 2.0
          )
        ),
        zoom: 12.0,
      )
    );
  }
  
  @override
  void dispose() {
    // Clean up annotations
    if (_pointAnnotationManager != null) {
      for (final annotation in _markerAnnotations) {
        _pointAnnotationManager!.delete(annotation);
      }
    }
    
    if (_polylineAnnotationManager != null) {
      for (final annotation in _routeAnnotations) {
        _polylineAnnotationManager!.delete(annotation);
      }
    }
    
    super.dispose();
  }
}

/// Represents a marker on the map
class LocationMarker {
  /// Unique identifier for this marker
  final String id;
  
  /// The location of the marker
  final LocationUpdate location;
  
  /// The image to use for the marker
  final String iconImage;
  
  /// The size of the marker
  final double iconSize;
  
  /// Optional label to display with the marker
  final String? label;
  
  const LocationMarker({
    required this.id,
    required this.location,
    required this.iconImage,
    this.iconSize = 1.0,
    this.label,
  });
}

/// Represents a route displayed on the map
class RouteDisplay {
  /// The route data to display
  final RouteData route;
  
  /// The color of the route line as a hex string
  final String colorHex;
  
  /// The width of the route line
  final double width;
  
  /// The opacity of the route line
  final double opacity;
  
  const RouteDisplay({
    required this.route,
    this.colorHex = "#3887be",
    this.width = 5.0,
    this.opacity = 0.8,
  });
}

/// Map style constants
class MapboxStyles {
  static const String MAPBOX_STREETS = 'mapbox://styles/mapbox/streets-v11';
  static const String MAPBOX_OUTDOORS = 'mapbox://styles/mapbox/outdoors-v11';
  static const String MAPBOX_LIGHT = 'mapbox://styles/mapbox/light-v10';
  static const String MAPBOX_DARK = 'mapbox://styles/mapbox/dark-v10';
  static const String MAPBOX_SATELLITE = 'mapbox://styles/mapbox/satellite-v9';
  static const String MAPBOX_SATELLITE_STREETS = 'mapbox://styles/mapbox/satellite-streets-v11';
  static const String MAPBOX_NAVIGATION_DAY = 'mapbox://styles/mapbox/navigation-day-v1';
  static const String MAPBOX_NAVIGATION_NIGHT = 'mapbox://styles/mapbox/navigation-night-v1';
} 