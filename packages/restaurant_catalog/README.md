<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Restaurant Catalog Module

A Flutter module for displaying and managing restaurant catalogs in a food delivery application.

## Features

- Restaurant listing with filtering and sorting
- Restaurant details view
- Menu item browsing and searching
- Category-based menu filtering
- Real-time data synchronization with Firebase

## Getting Started

### Dependencies

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  restaurant_catalog:
    path: packages/restaurant_catalog
```

### Usage

1. Initialize Firebase in your app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

2. Create a repository instance:

```dart
final firestore = FirebaseFirestore.instance;
final repository = FirestoreRestaurantRepository(firestore);
```

3. Create use cases:

```dart
final getRestaurantsUseCase = GetRestaurantsUseCase(repository);
final searchMenuItemsUseCase = SearchMenuItemsUseCase(repository);
```

4. Use the screens:

```dart
// Restaurant List Screen
RestaurantListScreen(
  getRestaurantsUseCase: getRestaurantsUseCase,
)

// Restaurant Detail Screen
RestaurantDetailScreen(
  restaurant: restaurant,
  repository: repository,
)
```

## Data Structure

### Restaurant Model
```dart
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
}
```

### Menu Item Model
```dart
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final List<String> ingredients;
  final Map<String, dynamic> customizationOptions;
}
```

## Firebase Setup

1. Create a new Firebase project
2. Enable Cloud Firestore
3. Set up security rules
4. Add the following collections:
   - `restaurants`
   - `menu_items`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
