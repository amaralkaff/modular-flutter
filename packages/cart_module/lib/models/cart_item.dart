import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String restaurantId;
  final String? imageUrl;
  final Map<String, dynamic>? customizations;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.restaurantId,
    this.imageUrl,
    this.customizations,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        quantity,
        restaurantId,
        imageUrl,
        customizations,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'restaurantId': restaurantId,
      'imageUrl': imageUrl,
      'customizations': customizations,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      restaurantId: json['restaurantId'] as String,
      imageUrl: json['imageUrl'] as String?,
      customizations: json['customizations'] as Map<String, dynamic>?,
    );
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? restaurantId,
    String? imageUrl,
    Map<String, dynamic>? customizations,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      restaurantId: restaurantId ?? this.restaurantId,
      imageUrl: imageUrl ?? this.imageUrl,
      customizations: customizations ?? this.customizations,
    );
  }
} 