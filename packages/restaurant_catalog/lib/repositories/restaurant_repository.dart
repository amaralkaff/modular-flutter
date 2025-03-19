import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants({
    String? cuisine,
    double? minRating,
    bool? isOpen,
    GeoPoint? location,
    double? maxDistance,
  });
  
  Future<Restaurant?> getRestaurantById(String id);
  
  Future<List<MenuItem>> getRestaurantMenu(String restaurantId);
  
  Future<List<MenuItem>> searchMenuItems(String query);
}

class FirestoreRestaurantRepository implements RestaurantRepository {
  final FirebaseFirestore _firestore;

  FirestoreRestaurantRepository(this._firestore);

  @override
  Future<List<Restaurant>> getRestaurants({
    String? cuisine,
    double? minRating,
    bool? isOpen,
    GeoPoint? location,
    double? maxDistance,
  }) async {
    Query query = _firestore.collection('restaurants');

    if (cuisine != null) {
      query = query.where('cuisine', isEqualTo: cuisine);
    }

    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    if (isOpen != null) {
      query = query.where('isOpen', isEqualTo: isOpen);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    final doc = await _firestore.collection('restaurants').doc(id).get();
    if (!doc.exists) return null;
    return Restaurant.fromFirestore(doc);
  }

  @override
  Future<List<MenuItem>> getRestaurantMenu(String restaurantId) async {
    final snapshot = await _firestore
        .collection('menu_items')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();
    
    return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MenuItem>> searchMenuItems(String query) async {
    final snapshot = await _firestore
        .collection('menu_items')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }
} 