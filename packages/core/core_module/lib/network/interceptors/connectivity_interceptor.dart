import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Interceptor that checks for network connectivity before making requests
class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();
  
  @override
  Future<void> onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      // If no connection, reject the request
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'No internet connection',
      );
      
      return handler.reject(error);
    }
    
    handler.next(options);
  }
} 