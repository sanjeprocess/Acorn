import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constant.dart';
import '../repositories/storage_repository.dart';
import './api_service.dart';

/// API client with token refresh functionality
class ApiClient extends ApiService {
  final StorageRepository _storageRepository;
  final Dio _refreshDio;

  ApiClient({required StorageRepository storageRepository, Dio? dio})
    : _storageRepository = storageRepository,
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ),
      super(baseUrl: ApiConstants.baseUrl, dio: dio) {
    // Add interceptor for automatic token refresh
    // Now using 'dio' rather than 'super._dio'
    dio?.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token has expired, try to refresh it
            if (await _refreshToken()) {
              // Retry the original request with new token
              return handler.resolve(await _retryRequest(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Initialize token from storage
    _initializeToken();
  }

  /// Initialize API with stored token
  Future<void> _initializeToken() async {
    final token = await _storageRepository.getString(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
    }
  }

  /// Refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageRepository.getString(
        StorageKeys.refreshToken,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      await _storageRepository.saveString(StorageKeys.token, newToken);

      if (newRefreshToken != null) {
        await _storageRepository.saveString(
          StorageKeys.refreshToken,
          newRefreshToken,
        );
      }

      setAuthToken(newToken);

      return true;
    } catch (e) {
      // Token refresh failed, user needs to log in again
      await _storageRepository.remove(StorageKeys.token);
      await _storageRepository.remove(StorageKeys.refreshToken);
      clearAuthToken();
      return false;
    }
  }

  /// Retry failed request with new token
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
