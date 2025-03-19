import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Interceptor that logs requests, responses, and errors for debugging purposes
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('🌎 REQUEST[${options.method}] => ${options.uri}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}\n'
          'Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e('⚠️ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}\n'
          'Message: ${err.message}\n'
          'Data: ${err.response?.data}');
    }
    handler.next(err);
  }
} 