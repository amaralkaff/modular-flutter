import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

/// Analytics event names
class AnalyticsEvents {
  AnalyticsEvents._();
  
  // Authentication events
  static const String login = 'login';
  static const String signup = 'signup';
  static const String logout = 'logout';
  
  // Screen view events
  static const String screenView = 'screen_view';
  
  // Restaurant events
  static const String viewRestaurant = 'view_restaurant';
  static const String searchRestaurants = 'search_restaurants';
  static const String filterRestaurants = 'filter_restaurants';
  
  // Menu events
  static const String viewMenuItem = 'view_menu_item';
  
  // Cart events
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String beginCheckout = 'begin_checkout';
  static const String addPaymentInfo = 'add_payment_info';
  static const String purchase = 'purchase';
  
  // Order events
  static const String viewOrder = 'view_order';
  static const String trackOrder = 'track_order';
  static const String rateOrder = 'rate_order';
}

/// Analytics parameter names
class AnalyticsParameters {
  AnalyticsParameters._();
  
  // Common
  static const String id = 'id';
  static const String name = 'name';
  static const String screenName = 'screen_name';
  static const String value = 'value';
  static const String source = 'source';
  static const String method = 'method';
  static const String status = 'status';
  
  // Item related
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String itemCategory = 'item_category';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String currency = 'currency';
  
  // Restaurant related
  static const String restaurantId = 'restaurant_id';
  static const String restaurantName = 'restaurant_name';
  static const String cuisineType = 'cuisine_type';
  static const String rating = 'rating';
  
  // Order related
  static const String orderId = 'order_id';
  static const String orderTotal = 'order_total';
  static const String orderStatus = 'order_status';
  static const String paymentMethod = 'payment_method';
  static const String deliveryAddress = 'delivery_address';
  
  // Search related
  static const String searchTerm = 'search_term';
  static const String filterType = 'filter_type';
  static const String filterValue = 'filter_value';
}

/// Application analytics service
@singleton
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  
  /// Constructor
  AnalyticsService(this._analytics);
  
  /// Get the FirebaseAnalytics instance
  FirebaseAnalytics get analytics => _analytics;
  
  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }
  
  /// Set user property
  Future<void> setUserProperty({
    required String name, 
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  /// Log a screen view event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
  
  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters as Map<String, Object>?,
    );
  }
  
  /// Log when a user logs in
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  /// Log when a user signs up
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }
  
  /// Log when a user adds an item to cart
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: itemCategory,
          price: price,
          quantity: quantity,
          currency: 'USD',
        ),
      ],
      currency: 'USD',
      value: price * quantity,
    );
  }
  
  /// Log when a user begins checkout
  Future<void> logBeginCheckout({
    required List<AnalyticsEventItem> items,
    required double value,
  }) async {
    await _analytics.logBeginCheckout(
      items: items,
      currency: 'USD',
      value: value,
    );
  }
  
  /// Log when a purchase is completed
  Future<void> logPurchase({
    required String orderId,
    required List<AnalyticsEventItem> items,
    required double value,
    required String paymentMethod,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      affiliation: 'Food Delivery App',
      items: items,
      currency: 'USD',
      value: value,
      shipping: 0,
      tax: 0,
      coupon: '',
    );
    
    // Log additional custom parameters
    await logEvent(
      name: AnalyticsEvents.purchase,
      parameters: {
        AnalyticsParameters.orderId: orderId,
        AnalyticsParameters.orderTotal: value,
        AnalyticsParameters.paymentMethod: paymentMethod,
      },
    );
  }
  
  /// Log when a restaurant is viewed
  Future<void> logViewRestaurant({
    required String restaurantId,
    required String restaurantName,
    String? cuisineType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.viewRestaurant,
      parameters: {
        AnalyticsParameters.restaurantId: restaurantId,
        AnalyticsParameters.restaurantName: restaurantName,
        if (cuisineType != null) AnalyticsParameters.cuisineType: cuisineType,
      },
    );
  }
  
  /// Log when a search is performed
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }
  
  /// Log when a restaurant filter is applied
  Future<void> logFilterRestaurants({
    required String filterType,
    required String filterValue,
  }) async {
    await logEvent(
      name: AnalyticsEvents.filterRestaurants,
      parameters: {
        AnalyticsParameters.filterType: filterType,
        AnalyticsParameters.filterValue: filterValue,
      },
    );
  }
} 