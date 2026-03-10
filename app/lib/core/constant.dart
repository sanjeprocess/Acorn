// lib/core/constants.dart

class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';

  // Validation
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const int minPasswordLength = 8;

  // Timeouts
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Error Messages
  static const String connectionErrorMessage =
      'Please check your internet connection';
  static const String generalErrorMessage =
      'Something went wrong, please try again later';
  static const String invalidCredentialsMessage = 'Invalid email or password';

  // Animation Durations
  static const int shortAnimationDuration = 250; // milliseconds
  static const int mediumAnimationDuration = 500; // milliseconds
  static const int longAnimationDuration = 800; // milliseconds

  static const String compassImageUrl = 'assets/images/compass.png';
  static const String acornLogo = 'assets/images/acorn_logo.png';
  static const String acornLoginLogo = 'assets/images/acorn_login_logo.png';
}
