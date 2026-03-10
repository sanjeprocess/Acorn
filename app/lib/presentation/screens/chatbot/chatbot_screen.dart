import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Assistant'),
      ),
      body: Center(
        child: Text(
          'Chatbot Screen',
          style: AppTheme.headerStyle,
        ),
      ),
    );
  }
}
