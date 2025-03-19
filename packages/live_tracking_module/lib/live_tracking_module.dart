library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import repositories
import 'repositories/map_repository.dart';
import 'repositories/location_repository.dart';

// Import services
import 'services/mapbox_service.dart';
import 'services/location_service.dart';

// Import bloc
import 'bloc/tracking_bloc.dart';

// Models
export 'models/location_update.dart';
export 'models/tracking_data.dart';
export 'models/route_data.dart';

// Repositories
export 'repositories/map_repository.dart';
export 'repositories/location_repository.dart';

// Services
export 'services/mapbox_service.dart';
export 'services/location_service.dart';

// BLoC
export 'bloc/tracking_bloc.dart';
export 'bloc/tracking_event.dart';
export 'bloc/tracking_state.dart';

// Screens
export 'screens/tracking_map_screen.dart';
export 'screens/delivery_status_screen.dart';

// Widgets
export 'widgets/delivery_progress_indicator.dart';
export 'widgets/driver_info_card.dart';

/// Initialize the module and load environment variables
Future<void> initializeLiveTrackingModule() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Live tracking module environment loaded successfully');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    debugPrint('Make sure you have a .env file in the project root directory');
  }
}

/// Sets up the Live Tracking Module by registering dependencies
void setupLiveTrackingModule() {
  final getIt = GetIt.instance;
  
  // Register services first
  if (!getIt.isRegistered<MapboxService>()) {
    getIt.registerLazySingleton<MapboxService>(
      () => MapboxService(),
    );
  }
  
  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(
      () => LocationService(),
    );
  }
  
  // Register repositories
  if (!getIt.isRegistered<MapRepository>()) {
    getIt.registerLazySingleton<MapRepository>(
      () => MapboxMapRepository(getIt<MapboxService>()),
    );
  }
  
  if (!getIt.isRegistered<LocationRepository>()) {
    getIt.registerLazySingleton<LocationRepository>(
      () => FirebaseLocationRepository(),
    );
  }
  
  // Register blocs
  if (!getIt.isRegistered<TrackingBloc>()) {
    getIt.registerFactory<TrackingBloc>(
      () => TrackingBloc(
        mapRepository: getIt<MapRepository>(),
        locationRepository: getIt<LocationRepository>(),
      ),
    );
  }
}

/// Provider widget for TrackingBloc
class TrackingBlocProvider extends StatelessWidget {
  final Widget child;
  
  const TrackingBlocProvider({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackingBloc>(
      create: (context) => GetIt.instance<TrackingBloc>(),
      child: child,
    );
  }
}
