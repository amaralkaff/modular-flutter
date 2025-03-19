import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:live_tracking_module/bloc/tracking_bloc.dart';
import 'package:live_tracking_module/bloc/tracking_state.dart';
import 'package:live_tracking_module/bloc/tracking_event.dart';
import 'package:live_tracking_module/models/location_update.dart';
import 'package:live_tracking_module/models/route_data.dart';
import 'package:live_tracking_module/models/tracking_data.dart';
import 'package:live_tracking_module/repositories/map_repository.dart';
import 'package:live_tracking_module/widgets/delivery_progress_indicator.dart';
import 'package:live_tracking_module/widgets/driver_info_card.dart';
import 'package:live_tracking_module/widgets/map_widget.dart';

/// Screen that displays a map with real-time tracking information
class TrackingMapScreen extends StatefulWidget {
  /// ID of the order to track
  final String orderId;
  
  const TrackingMapScreen({
    super.key,
    required this.orderId,
  });
  
  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PointAnnotation? _driverAnnotation;
  PointAnnotation? _restaurantAnnotation;
  PointAnnotation? _customerAnnotation;
  final List<PolylineAnnotation> _routeLines = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state is TrackingInitial) {
            return const Center(child: Text('Initializing tracking...'));
          } else if (state is TrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TrackingActive || 
                     state is RouteCalculating || 
                     state is RouteCalculated) {
            final trackingData = state is TrackingActive 
                ? state.trackingData 
                : state is RouteCalculating 
                    ? state.trackingData 
                    : (state as RouteCalculated).trackingData;
            
            return _buildTrackingMap(context, trackingData);
          } else if (state is TrackingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TrackingBloc>().add(
                            StartTrackingListenEvent(widget.orderId),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Unknown tracking state'),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildTrackingMap(BuildContext context, TrackingData trackingData) {
    final mapRepository = context.read<MapRepository>();
    
    return Stack(
      children: [
        CustomMapView(
          initialCameraPosition: CameraOptions(
            center: Point(
              coordinates: Position(
                trackingData.customerLocation.longitude,
                trackingData.customerLocation.latitude,
              )
            ),
            zoom: 13.0,
          ),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: () => _updateMapData(trackingData),
          myLocationEnabled: false,
          interactive: true,
        ),
        
        // Bottom card with driver info and delivery progress
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trackingData.driverLocation != null)
                DriverInfoCard(trackingData: trackingData),
              DeliveryProgressIndicator(trackingData: trackingData),
            ],
          ),
        ),
        
        // Center on locations buttons
        Positioned(
          left: 16,
          top: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "fitAllMarkers",
                onPressed: () => _fitAllMarkers(trackingData),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                child: const Icon(Icons.fullscreen),
              ),
              const SizedBox(height: 8),
              if (trackingData.driverLocation != null)
                FloatingActionButton.small(
                  heroTag: "centerOnDriver",
                  onPressed: () => _centerOnLocation(trackingData.driverLocation!),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  child: const Icon(Icons.local_shipping),
                ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "centerOnRestaurant",
                onPressed: () => _centerOnLocation(trackingData.restaurantLocation),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                child: const Icon(Icons.restaurant),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "centerOnCustomer",
                onPressed: () => _centerOnLocation(trackingData.customerLocation),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                child: const Icon(Icons.home),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _onMapCreated(MapboxMap mapboxMap) {
    setState(() {
      _mapboxMap = mapboxMap;
    });
    
    // Create annotation managers
    mapboxMap.annotations.createPointAnnotationManager().then((manager) {
      _pointAnnotationManager = manager;
    });
    
    mapboxMap.annotations.createPolylineAnnotationManager().then((manager) {
      _polylineAnnotationManager = manager;
    });
  }
  
  Future<void> _updateMapData(TrackingData trackingData) async {
    // Clear existing annotations
    await _clearMapObjects();
    
    if (_pointAnnotationManager == null || _polylineAnnotationManager == null) return;
    
    // Add restaurant marker
    await _addRestaurantMarker(trackingData.restaurantLocation);
    
    // Add customer marker
    await _addCustomerMarker(trackingData.customerLocation);
    
    // Add driver marker if available
    if (trackingData.driverLocation != null) {
      await _addDriverMarker(trackingData.driverLocation!);
    }
    
    // Add route lines if available
    if (trackingData.driverToRestaurantRoute != null) {
      await _addRouteLine(trackingData.driverToRestaurantRoute!);
    }
    
    if (trackingData.restaurantToCustomerRoute != null) {
      await _addRouteLine(trackingData.restaurantToCustomerRoute!);
    }
    
    if (trackingData.driverToCustomerRoute != null) {
      await _addRouteLine(trackingData.driverToCustomerRoute!);
    }
    
    // Fit map to show all points
    _fitAllMarkers(trackingData);
  }
  
  Future<void> _addDriverMarker(LocationUpdate location) async {
    if (_pointAnnotationManager == null) return;
    
    try {
      final options = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(location.longitude, location.latitude)
        ),
        textField: "Driver",
        textOffset: [0, 1.5],
        textColor: Colors.black.value,
        textSize: 12,
      );
      
      _driverAnnotation = await _pointAnnotationManager!.create(options);
    } catch (e) {
      debugPrint('Error adding driver marker: $e');
    }
  }
  
  Future<void> _addRestaurantMarker(LocationUpdate location) async {
    if (_pointAnnotationManager == null) return;
    
    try {
      final options = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(location.longitude, location.latitude)
        ),
        textField: "Restaurant",
        textOffset: [0, 1.5],
        textColor: Colors.black.value,
        textSize: 12,
      );
      
      _restaurantAnnotation = await _pointAnnotationManager!.create(options);
    } catch (e) {
      debugPrint('Error adding restaurant marker: $e');
    }
  }
  
  Future<void> _addCustomerMarker(LocationUpdate location) async {
    if (_pointAnnotationManager == null) return;
    
    try {
      final options = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(location.longitude, location.latitude)
        ),
        textField: "You",
        textOffset: [0, 1.5],
        textColor: Colors.black.value,
        textSize: 12,
      );
      
      _customerAnnotation = await _pointAnnotationManager!.create(options);
    } catch (e) {
      debugPrint('Error adding customer marker: $e');
    }
  }
  
  Future<void> _addRouteLine(RouteData route) async {
    if (_polylineAnnotationManager == null) return;
    
    try {
      final points = route.points.map((point) {
        return Position(point.longitude, point.latitude);
      }).toList();
      
      final options = PolylineAnnotationOptions(
        geometry: LineString(coordinates: points),
        lineColor: Colors.blue.value,
        lineWidth: 4.0,
      );
      
      final polyline = await _polylineAnnotationManager!.create(options);
      _routeLines.add(polyline);
    } catch (e) {
      debugPrint('Error adding route line: $e');
    }
  }
  
  Future<void> _clearMapObjects() async {
    if (_pointAnnotationManager != null) {
      await _pointAnnotationManager!.deleteAll();
    }
    
    if (_polylineAnnotationManager != null) {
      await _polylineAnnotationManager!.deleteAll();
    }
    
    _driverAnnotation = null;
    _restaurantAnnotation = null;
    _customerAnnotation = null;
    _routeLines.clear();
  }
  
  void _centerOnLocation(LocationUpdate location) {
    if (_mapboxMap == null) return;
    
    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(location.longitude, location.latitude)
      ),
      zoom: 15.0,
    );
    
    _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 500));
  }
  
  void _fitAllMarkers(TrackingData trackingData) {
    if (_mapboxMap == null) return;
    
    final locations = <LocationUpdate>[
      trackingData.restaurantLocation,
      trackingData.customerLocation,
    ];
    
    if (trackingData.driverLocation != null) {
      locations.add(trackingData.driverLocation!);
    }
    
    // Calculate bounds
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
    
    // Use a simpler approach with setCamera to the center with appropriate zoom
    final centerLat = (minLat + maxLat) / 2.0;
    final centerLng = (minLng + maxLng) / 2.0;
    
    _mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(centerLng, centerLat)
        ),
        zoom: 11.0, // A bit zoomed out to show all markers
      )
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
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