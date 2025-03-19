/// Routes constants for the app
class Routes {
  Routes._();
  
  /// Splash screen
  static const String splash = '/splash';
  
  /// Home screen
  static const String home = '/home';
  
  /// Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  /// Restaurant related
  static const String restaurants = '/restaurants';
  static const String restaurantDetails = '/restaurant/:id';
  static const String menuItem = '/restaurant/:id/menu/:itemId';
  
  /// Cart and checkout
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/add-payment-method';
  static const String orderConfirmation = '/order-confirmation';
  
  /// Orders
  static const String orders = '/orders';
  static const String orderDetails = '/order/:id';
  static const String orderTracking = '/order/:id/tracking';
  
  /// Profile
  static const String profile = '/profile';
  static const String addresses = '/addresses';
  static const String editAddress = '/edit-address';
  static const String settings = '/settings';
} 