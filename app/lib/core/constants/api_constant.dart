/// API related constants
class ApiConstants {
  ApiConstants._();

  /// Base API URL
  static const String baseUrl =
      'https://walletapi.acorn.lk/api/v1';
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  /// Auth endpoints
  static const String login = '/auth/loginCustomer';
  static const String register = '/auth/updateCustomerPassword';
  static const String logout = '/auth/logout';
  static const String isPasswordAvailable = '/auth/checkPassword';
  static const String refreshToken = '/auth/refresh-token';

  ///Forget Password
  static const String sendOtp = '/forgot-password/send-otp';
  static const String verifyOtp = '/forgot-password/verify-otp';
  static const String resendOtp = '/forgot-password/resend-otp';
  static const String resetPassword = '/forgot-password/reset';

  /// User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';

  /// Travel endpoints
  static const String travels = '/travels';
  static const String feedback = '/feedback';
  static const String updateTravel = '$travels/updateTravel';
  static const String travelFeedback = '/feedback/travel';
  static const String userFeedback = '/feedback/customer';

  /// Incident endpoints
  static const String incidents = '/incidentReport';

  /// Notifications endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead =
      '/notifications/read/'; // Append ID

  /// document upload endpoints
  static const String uploadDocuments = '/travels/upload';
  static const String deleteDocs = '/travels/docs';
}

/// Storage keys for local storage
class StorageKeys {
  StorageKeys._();

  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user_data';
  static const String isFirstLaunch = 'is_first_launch';
  static const String isDarkMode = 'is_dark_mode';
}
