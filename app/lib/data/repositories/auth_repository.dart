import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository that handles authentication use cases
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  /// Login user with email and password
  Future<UserModel> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    return await _authService.register(email: email, password: password);
  }

  /// Send password reset instructions to user's email
  Future<void> sendOtp(String email) async {
    await _authService.sendOtp(email);
  }

  Future<void> resendOtp(String email) async {
    await _authService.resendOtp(email);
  }

  Future<void> verifyOtp(String email, String otp) async {
    await _authService.verifyOtp(email, otp);
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    await _authService.resetPassword(email: email, password: password);
  }

  /// Check if password is available for the given email
  Future<bool> isPasswordAvailable({required String email}) async {
    return await _authService.isPasswordAvailable(email: email);
  }

  /// Logout current user
  Future<void> logout() async {
    await _authService.logout();
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  /// Get the currently logged in user
  Future<UserModel?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }
}
