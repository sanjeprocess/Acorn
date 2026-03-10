import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Text(
          'Signup Screen',
          style: AppTheme.headerStyle,
        ),
      ),
    );
  }
}
