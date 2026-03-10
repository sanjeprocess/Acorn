import 'dart:developer';

import 'package:arcon_travel_app/core/constant.dart';
import 'package:arcon_travel_app/presentation/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../routes.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Define login states to manage UI flow
enum LoginState {
  emailEntry, // Initial state - only email field is shown
  existingUser, // Email exists - show password field
  newUser, // New email - show create password fields
  loading, // Processing API calls
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  String? _errorMessage;
  String _version = '';

  // Current state of the login flow
  LoginState _loginState = LoginState.emailEntry;

  // Separate loading flags for API operations
  bool _isCheckingEmail = false;
  bool _isLoggingIn = false;
  bool _isCreatingAccount = false;

  // Get repositories from dependency injection
  final _authRepository = locator<AuthRepository>();
  final _storageRepository = locator<StorageRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments['resetPassword'] != null) {
        if (arguments['resetPassword'] == true) {
          isRestedPassword(arguments['email']);
        }
      }
    });
    _loadSavedCredentials();
  }

  Future<void> _getVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = "v${packageInfo.version}";
    });
  }

  isRestedPassword(String email) {
    setState(() {
      _emailController.text = email;
      _loginState = LoginState.existingUser;
    });
  }

  Future<void> _loadSavedCredentials() async {
    // Show loading indicator
    setState(() {
      _isCheckingEmail = true;
    });

    try {
      final savedEmail = await _storageRepository.getString('saved_email');
      final savedPassword = await _storageRepository.getString(
        'saved_password',
      );
      final wasRemembered =
          await _storageRepository.getBool('remember_me') ?? false;

      if (savedEmail != null && savedPassword != null && wasRemembered) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
          // If we have saved credentials, we can assume it's an existing user
          _loginState = LoginState.existingUser;
        });
      }
    } catch (e) {
      // Handle any error silently during initial load
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
      }
      _getVersion();
    }
  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      await _storageRepository.saveString('saved_email', _emailController.text);
      await _storageRepository.saveString(
        'saved_password',
        _passwordController.text,
      );
      await _storageRepository.saveBool('remember_me', true);
    } else {
      // Clear saved credentials if remember me is toggled off
      await _storageRepository.remove('saved_email');
      await _storageRepository.remove('saved_password');
      await _storageRepository.saveBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check if the email has a password associated with it
  Future<void> _checkEmailPassword() async {
    // Validate email first
    if (_emailController.text.isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    // Show loading indicator for email check
    setState(() {
      _isCheckingEmail = true;
      _errorMessage = null;
    });

    try {
      // Call the API to check if password exists for this email
      final isPasswordAvailable = await _authRepository.isPasswordAvailable(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          // Set state based on API response
          _loginState =
              isPasswordAvailable
                  ? LoginState.existingUser
                  : LoginState.newUser;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _loginState = LoginState.emailEntry;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
      }
    }
  }

  // Handle login for existing users
  Future<void> _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Clear previous error messages and show loading
    setState(() {
      _errorMessage = null;
      _isLoggingIn = true;
    });

    try {
      // Save credentials if remember me is checked
      await _saveCredentials();

      // Actual login call to API
      await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Navigate to home on successful login
        AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
      }
    } catch (e) {
      // Handle login error
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  // Handle account creation for new users
  Future<void> _handleCreateAccount() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Clear previous error messages and show loading
    setState(() {
      _errorMessage = null;
      _isCreatingAccount = true;
    });

    try {
      // Register the new user
      await _authRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully. Please login.',
              style: TextStyle(color: AppTheme.whiteColor),
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );

        // Reset to login state
        setState(() {
          _loginState = LoginState.existingUser;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      // Handle registration error
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAccount = false;
        });
      }
    }
  }

  // Reset the form to email entry state
  void _resetForm() {
    setState(() {
      _loginState = LoginState.emailEntry;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      appBar: AppBar(
        leading:
            _loginState != LoginState.emailEntry
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _resetForm,
                )
                : null,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Align(alignment: Alignment.topRight, child: Text(_version)),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        AppConstants.acornLoginLogo,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Title based on current state
                    Text(
                      _getScreenTitle(),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),

                    // Global loading indicator - shown during initial load
                    if (_isCheckingEmail &&
                        _loginState == LoginState.emailEntry) ...[
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Input (always visible)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: AppTheme.whiteColor,
                      enabled:
                          _loginState == LoginState.emailEntry &&
                          !_isCheckingEmail,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Conditional UI based on login state
                    if (_loginState == LoginState.emailEntry) ...[
                      // Continue button for email entry
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isCheckingEmail ? null : _checkEmailPassword,
                          style: AppTheme.primaryButtonStyle,
                          child:
                              _isCheckingEmail
                                  ? _buildLoadingIndicator()
                                  : Text(
                                    'Continue',
                                    style: theme.textTheme.labelLarge,
                                  ),
                        ),
                      ),
                    ]
                    // For existing users (show password field)
                    else if (_loginState == LoginState.existingUser) ...[
                      // Password Input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        enabled: !_isLoggingIn,
                        cursorColor: AppTheme.whiteColor,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed:
                                _isLoggingIn
                                    ? null
                                    : () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 5),

                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged:
                                _isLoggingIn
                                    ? null
                                    : (bool? value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                          ),
                          Text(
                            'Remember Me',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          InkWell(
                            onTap:
                                _isLoggingIn
                                    ? null
                                    : () {
                                      AppRoutes.navigateTo(
                                        context,
                                        AppRoutes.forgotPassword,
                                        arguments: {
                                          'email':
                                              _emailController.text
                                                  .trim()
                                                  .toString(),
                                        },
                                      );
                                    },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoggingIn ? null : _handleLogin,
                          style: AppTheme.primaryButtonStyle,
                          child:
                              _isLoggingIn
                                  ? _buildLoadingIndicator()
                                  : Text(
                                    'Login',
                                    style: theme.textTheme.labelLarge,
                                  ),
                        ),
                      ),
                    ]
                    // For new users (show password creation fields)
                    else if (_loginState == LoginState.newUser) ...[
                      // Create Password field
                      TextFormField(
                        cursorColor: AppTheme.whiteColor,
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        enabled: !_isCreatingAccount,
                        decoration: InputDecoration(
                          hintText: 'Create Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed:
                                _isCreatingAccount
                                    ? null
                                    : () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please create a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password field
                      TextFormField(
                        cursorColor: AppTheme.whiteColor,
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        enabled: !_isCreatingAccount,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed:
                                _isCreatingAccount
                                    ? null
                                    : () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 5),

                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged:
                                _isCreatingAccount
                                    ? null
                                    : (bool? value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                          ),
                          Text(
                            'Remember Me',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Create Account Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isCreatingAccount ? null : _handleCreateAccount,
                          style: AppTheme.primaryButtonStyle,
                          child:
                              _isCreatingAccount
                                  ? _buildLoadingIndicator()
                                  : Text(
                                    'Create Account',
                                    style: theme.textTheme.labelLarge,
                                  ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a consistent loading indicator
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppTheme.whiteColor,
      ),
    );
  }

  // Helper method to get the appropriate screen title based on state
  String _getScreenTitle() {
    switch (_loginState) {
      case LoginState.emailEntry:
        return 'Welcome';
      case LoginState.existingUser:
        return 'Login';
      case LoginState.newUser:
        return 'Create Account';
      case LoginState.loading:
        return _loginState == LoginState.emailEntry
            ? 'Welcome'
            : _loginState == LoginState.existingUser
            ? 'Login'
            : 'Create Account';
    }
  }
}
