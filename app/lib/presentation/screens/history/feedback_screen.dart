import 'package:arcon_travel_app/presentation/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AddFeedbackScreen extends StatelessWidget {
  final String historyId;
  final String? existingFeedback;

  const AddFeedbackScreen({
    super.key,
    required this.historyId,
    this.existingFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Add Feedback')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Add Feedback Screen', style: AppTheme.headerStyle),
            const SizedBox(height: 16),
            Text('For Trip ID: $historyId', style: AppTheme.bodyStyle),
            if (existingFeedback != null) ...[
              const SizedBox(height: 8),
              Text(
                'Existing Feedback: $existingFeedback',
                style: AppTheme.bodyStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
