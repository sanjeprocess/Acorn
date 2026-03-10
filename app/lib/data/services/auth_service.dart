import 'dart:developer';

import '../models/user_model.dart';
import 'api_service.dart';
import '../../core/constants/api_constant.dart';
import '../repositories/storage_repository.dart';

/// Authentication service responsible for login, register, and token management
class AuthService {
  final ApiService _apiService;
  final StorageRepository _storageRepository;
  final String userType = "Customer";

  AuthService({
    required ApiService apiService,
    required StorageRepository storageRepository,
  }) : _apiService = apiService,
       _storageRepository = storageRepository;

  /// Login with email and password
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final userData = response.data['data']['customer'];

      final token = response.data['data']['accessToken'];
      final refreshToken = response.data['data']['refreshToken'];

      // Save token and user data to storage
      await _storageRepository.saveString(StorageKeys.token, token);

      if (refreshToken != null) {
        await _storageRepository.saveString(
          StorageKeys.refreshToken,
          refreshToken,
        );
      }

      // Update API service with the new token
      _apiService.setAuthToken(token);

      // Parse and save user data
      final user = UserModel.fromJson(userData);
      await _storageRepository.saveJson(StorageKeys.user, user.toJson());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.register,
        data: {'email': email, 'password': password},
      );

      log('${response.data}');

      if (response.data != null) {
        return response.data['success'];
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Forgot password - sends a reset link to user's email
  Future<void> sendOtp(String email) async {
    try {
      await _apiService.post(
        ApiConstants.sendOtp,
        data: {'email': email, 'userType': "Customer"},
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Reset password with token received via email
  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'newPassword': password, 'userType': "Customer"},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout the user
  Future<void> logout() async {
    try {
      // Get token from storage
      final token = await _storageRepository.getString(StorageKeys.token);

      if (token != null) {
        // Set token for this request
        _apiService.setAuthToken(token);

        // Call logout endpoint (ignoring errors if it fails)
        try {
          await _apiService.post(ApiConstants.logout);
        } catch (e) {
          // Silent failure as we want to clear local data regardless
        }
      }

      // Clear API service token
      _apiService.clearAuthToken();

      // Clear stored tokens and user data
      await _storageRepository.remove(StorageKeys.token);
      await _storageRepository.remove(StorageKeys.refreshToken);
      await _storageRepository.remove(StorageKeys.user);
    } catch (e) {
      // Ensure token is cleared even if there's an error
      _apiService.clearAuthToken();
      await _storageRepository.remove(StorageKeys.token);
      await _storageRepository.remove(StorageKeys.refreshToken);
      await _storageRepository.remove(StorageKeys.user);

      rethrow;
    }
  }

  /// Check if user is logged in (has a stored token)
  Future<bool> isLoggedIn() async {
    final token = await _storageRepository.getString(StorageKeys.token);
    return token != null && token.isNotEmpty;
  }

  /// Get the current user from storage
  Future<UserModel?> getCurrentUser() async {
    final userData = await _storageRepository.getJson(StorageKeys.user);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  /// Register a new user
  Future<bool> isPasswordAvailable({required String email}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.isPasswordAvailable,
        queryParameters: {'email': email},
      );

      if (response.data != null) {
        return response.data['data']['isPasswordAvailable'];
      }
      return false;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Refresh token when it expires
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageRepository.getString(
        StorageKeys.refreshToken,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _apiService.post(
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

      _apiService.setAuthToken(newToken);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _apiService.post(
        ApiConstants.resendOtp,
        data: {'email': email, 'userType': "Customer"},
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _apiService.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp, 'userType': "Customer"},
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}
