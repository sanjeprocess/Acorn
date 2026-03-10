import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Base API service using Dio for network requests
class ApiService {
  final String baseUrl;
  // Changed from private to protected (with _ but accessible to subclasses)
  final Dio dio;

  /// Initialize with baseUrl and optional Dio instance
  ApiService({required this.baseUrl, Dio? dio}) : dio = dio ?? Dio() {
    this.dio.options.baseUrl = baseUrl;
    this.dio.options.connectTimeout = const Duration(seconds: 30);
    this.dio.options.receiveTimeout = const Duration(seconds: 30);
    this.dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor to handle multipart requests
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // For multipart requests, remove the Content-Type header
          // Dio will automatically set the correct multipart header
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
          }
          return handler.next(options);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      this.dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// Add auth token to requests
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Standardized error handling
  String _handleError(DioException error) {
    String errorMessage = 'An unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timed out';
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 401) {
          errorMessage =
              responseData['error']['message'] ??
              'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage =
              responseData['error']['message'] ??
              'You don\'t have permission to access this resource';
        } else if (statusCode == 404) {
          errorMessage =
              responseData['error']['message'] ?? 'Resource not found';
        } else if (statusCode == 500) {
          errorMessage =
              responseData['error']['message'] ??
              'Something went wrong. Please try again shortly.';
        } else if (responseData != null && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request canceled';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Invalid certificate';
        break;

      case DioExceptionType.connectionError:
        errorMessage =
            'Waiting to connect to the server. Please try again shortly.';
        break;

      case DioExceptionType.unknown:
        if (error.message != null) {
          errorMessage = error.message!;
        }
        break;
    }

    return errorMessage;
  }
}
