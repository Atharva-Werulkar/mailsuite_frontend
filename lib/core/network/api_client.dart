import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_constants.dart';

/// HTTP Client for API Communication
class ApiClient {
  late final Dio _dio;
  final SupabaseClient _supabase;

  ApiClient(this._supabase) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': ApiConstants.contentTypeJson,
          'Accept': ApiConstants.acceptJson,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_supabase));
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  /// GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio Errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'Unknown error occurred';

        // Try to extract error message from response
        if (error.response?.data != null) {
          final data = error.response!.data;
          print('🔍 [ApiClient] Response data type: ${data.runtimeType}');
          print('🔍 [ApiClient] Response data: $data');

          if (data is Map<String, dynamic>) {
            // Check for common error message fields
            message =
                data['error'] as String? ??
                data['message'] as String? ??
                data['error_description'] as String? ??
                message;
            print('📝 [ApiClient] Extracted message: $message');
          } else if (data is String) {
            message = data;
          }
        }

        print(
          '⚠️ [ApiClient] Final error: Server error ($statusCode): $message',
        );
        return Exception(message);
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.unknown:
        return Exception(
          'Network error. Please check your internet connection.',
        );
      default:
        return Exception('An unexpected error occurred');
    }
  }
}

/// Authentication Interceptor for JWT Token
class _AuthInterceptor extends Interceptor {
  final SupabaseClient _supabase;

  _AuthInterceptor(this._supabase);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get JWT token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('🔑 [AuthInterceptor] Added JWT token to request: ${options.uri}');
    } else {
      print('⚠️ [AuthInterceptor] No access token found for: ${options.uri}');
    }
    
    handler.next(options);
  }
}
