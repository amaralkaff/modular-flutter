import 'package:dio/dio.dart';

/// Interceptor that adds authentication token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Get token from secure storage
    // final token = await secureStorage.getToken();
    const String? token = null;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Handle token refresh or redirect to login
    }
    
    handler.next(err);
  }
} 