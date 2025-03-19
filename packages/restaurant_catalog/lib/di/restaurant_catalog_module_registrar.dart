import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:restaurant_catalog/repositories/restaurant_repository.dart';
import 'package:restaurant_catalog/domain/use_cases/get_restaurants_use_case.dart';
import 'package:restaurant_catalog/domain/use_cases/search_menu_items_use_case.dart';

/// Restaurant catalog module registrar that registers all dependencies for the restaurant catalog module
class RestaurantCatalogModuleRegistrar {
  final GetIt _getIt;
  
  RestaurantCatalogModuleRegistrar(this._getIt);
  
  Future<void> register() async {
    // Register repositories
    if (!_getIt.isRegistered<RestaurantRepository>()) {
      final firestore = FirebaseFirestore.instance;
      _getIt.registerLazySingleton<RestaurantRepository>(
        () => FirestoreRestaurantRepository(firestore),
      );
    }
    
    // Register use cases
    if (!_getIt.isRegistered<GetRestaurantsUseCase>()) {
      _getIt.registerFactory<GetRestaurantsUseCase>(
        () => GetRestaurantsUseCase(_getIt<RestaurantRepository>()),
      );
    }
    
    if (!_getIt.isRegistered<SearchMenuItemsUseCase>()) {
      _getIt.registerFactory<SearchMenuItemsUseCase>(
        () => SearchMenuItemsUseCase(_getIt<RestaurantRepository>()),
      );
    }
  }
} 