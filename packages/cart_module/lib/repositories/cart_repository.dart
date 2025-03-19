import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartRepository {
  static const String _boxName = 'cart_box';
  final Box _box;
  final FirebaseFirestore _firestore;
  final String userId;

  CartRepository({
    required Box box,
    required FirebaseFirestore firestore,
    required this.userId,
  })  : _box = box,
        _firestore = firestore;

  Future<void> addItem(CartItem item) async {
    final items = await getItems();
    final existingItemIndex = items.indexWhere((i) => i.id == item.id);
    
    if (existingItemIndex != -1) {
      final existingItem = items[existingItemIndex];
      items[existingItemIndex] = CartItem(
        id: existingItem.id,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + item.quantity,
        restaurantId: existingItem.restaurantId,
        imageUrl: existingItem.imageUrl,
        customizations: existingItem.customizations,
      );
    } else {
      items.add(item);
    }

    await _saveItems(items);
    await _syncWithCloud(items);
  }

  Future<void> removeItem(String itemId) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveItems(items);
    await _syncWithCloud(items);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      final item = items[index];
      items[index] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: quantity,
        restaurantId: item.restaurantId,
        imageUrl: item.imageUrl,
        customizations: item.customizations,
      );
      await _saveItems(items);
      await _syncWithCloud(items);
    }
  }

  Future<List<CartItem>> getItems() async {
    final data = _box.get('items', defaultValue: <Map<String, dynamic>>[]);
    if (data is List) {
      return data.map((item) {
        if (item is Map) {
          return CartItem.fromJson(Map<String, dynamic>.from(item));
        }
        return CartItem(
          id: 'error',
          name: 'Error Item',
          price: 0,
          quantity: 0,
          restaurantId: 'none',
        );
      }).toList();
    }
    return [];
  }

  Future<void> clearCart() async {
    await _box.delete('items');
    await _syncWithCloud([]);
  }

  Future<double> getTotal() async {
    final items = await getItems();
    return items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _saveItems(List<CartItem> items) async {
    await _box.put('items', items.map((item) => item.toJson()).toList());
  }

  Future<void> _syncWithCloud(List<CartItem> items) async {
    await _firestore.collection('carts').doc(userId).set({
      'items': items.map((item) => item.toJson()).toList(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
} 