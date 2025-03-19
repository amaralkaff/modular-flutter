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
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 0,
      cuisine: data['cuisine']?.toString() ?? '',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      estimatedDeliveryTime: (data['estimatedDeliveryTime'] as num?)?.toInt() ?? 30,
      isOpen: data['isOpen'] as bool? ?? false,
      location: (data['location'] as GeoPoint?) ?? const GeoPoint(0, 0),
      menuCategories: (data['menuCategories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      operatingHours: (data['operatingHours'] as Map<String, dynamic>?) ?? {},
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