import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class GetRestaurantsUseCase {
  final RestaurantRepository _repository;

  GetRestaurantsUseCase(this._repository);

  Future<List<Restaurant>> execute({
    String? cuisine,
    double? minRating,
    bool? isOpen,
    GeoPoint? location,
    double? maxDistance,
  }) async {
    try {
      final restaurants = await _repository.getRestaurants(
        cuisine: cuisine,
        minRating: minRating,
        isOpen: isOpen,
        location: location,
        maxDistance: maxDistance,
      );

      // Sort by rating if no other sorting criteria is specified
      if (location == null) {
        restaurants.sort((a, b) => b.rating.compareTo(a.rating));
      }

      return restaurants;
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }
} 