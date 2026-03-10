import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = locator<AuthRepository>();

  // State management
  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Timer for resend OTP
  int _resendTimer = 0;

  @override
  void initState() {
    super.initState();
    // Get email from route arguments after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments['email'] != null) {
        _emailController.text = arguments['email'] as String;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Send OTP function
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make API call to send OTP
      await _authRepository.sendOtp(_emailController.text);

      setState(() {
        _otpSent = true;
        _isLoading = false;
        _startResendTimer();
      });

      _showSnackBar(
        'OTP sent to ${_emailController.text}',
        AppTheme.primaryColor,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        'Failed to send OTP. Please try again.',
        AppTheme.primaryColor,
      );
    }
  }

  // Validate OTP function
  Future<void> _validateOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP', AppTheme.primaryColor);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make API call to validate OTP
      await _authRepository.verifyOtp(
        _emailController.text,
        _otpController.text,
      );

      setState(() {
        _otpVerified = true;
        _isLoading = false;
      });
      _showSnackBar('OTP verified successfully', AppTheme.primaryColor);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Invalid OTP. Please try again.', AppTheme.primaryColor);
    }
  }

  // Resend OTP function
  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
      _otpController.clear();
    });

    try {
      // Make API call to resend OTP
      await _authRepository.resendOtp(_emailController.text);

      setState(() {
        _isLoading = false;
        _startResendTimer();
      });

      _showSnackBar(
        'OTP resent to ${_emailController.text}',
        AppTheme.primaryColor,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        'Failed to resend OTP. Please try again.',
        AppTheme.primaryColor,
      );
    }
  }

  // Reset password function
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make API call to reset password
      await _authRepository.resetPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Password reset successfully', AppTheme.primaryColor);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/login',
          arguments: {
            'resetPassword': true,
            'email': _emailController.text.trim(),
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        'Password reset failed. Please try again.',
        AppTheme.primaryColor,
      );
    }
  }

  // Start resend timer
  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });

    _countDown();
  }

  void _countDown() {
    if (_resendTimer > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendTimer--;
          });
          _countDown();
        }
      });
    }
  }

  // Show snackbar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  // Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Reset Your Password',
                style: AppTheme.headerStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address to receive OTP and reset your password',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Input Section
              if (!_otpVerified) ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_otpSent, // Disable once OTP is sent
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _otpSent) ? null : _sendOtp,
                    child:
                        _isLoading && !_otpSent
                            ? const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            )
                            : Text(
                              _otpSent ? 'OTP Sent' : 'Send OTP',
                              style: const TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Step 2: OTP Verification
              if (_otpSent && !_otpVerified) ...[
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'OTP has been sent to ${_emailController.text}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Enter 6-digit OTP',
                    hintText: '000000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, letterSpacing: 4),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _resendTimer > 0 ? null : _resendOtp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _resendTimer > 0
                                  ? Colors.grey.shade200
                                  : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _resendTimer > 0
                                    ? Colors.grey.shade300
                                    : AppTheme.primaryColor,
                          ),
                        ),
                        child: Text(
                          _resendTimer > 0
                              ? 'Resend in ${_resendTimer}s'
                              : 'Resend OTP',
                          style: TextStyle(
                            color:
                                _resendTimer > 0
                                    ? Colors.grey.shade600
                                    : AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _validateOtp,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Verify OTP'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Step 3: Reset Password
              if (_otpVerified) ...[
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OTP verified successfully for ${_emailController.text}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Re-enter your new password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_confirmPasswordVisible,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            )
                            : const Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStepHeader(String title, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isActive ? Icons.check : Icons.radio_button_unchecked,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
