import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int totalRatings;
  final String cuisine;
  final double deliveryFee;
  final int estimatedDeliveryTime;
  final bool isOpen;
  final GeoPoint location;
  final List<String> menuCategories;
  final Map<String, dynamic> operatingHours;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.totalRatings,
    required this.cuisine,
    required this.deliveryFee,
    required this.estimatedDeliveryTime,
    required this.isOpen,
    required this.location,
    required this.menuCategories,
    required this.operatingHours,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      cuisine: data['cuisine'] ?? '',
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: data['estimatedDeliveryTime'] ?? 30,
      isOpen: data['isOpen'] ?? false,
      location: data['location'] ?? const GeoPoint(0, 0),
      menuCategories: List<String>.from(data['menuCategories'] ?? []),
      operatingHours: data['operatingHours'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalRatings': totalRatings,
      'cuisine': cuisine,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'isOpen': isOpen,
      'location': location,
      'menuCategories': menuCategories,
      'operatingHours': operatingHours,
    };
  }
} 