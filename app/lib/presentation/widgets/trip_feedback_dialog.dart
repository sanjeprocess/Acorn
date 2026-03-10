import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme.dart';

class TripFeedbackDialog extends StatefulWidget {
  final Function(double rating, String comment) onSubmit;
  final VoidCallback? onCancel;

  const TripFeedbackDialog({super.key, required this.onSubmit, this.onCancel});

  @override
  State<TripFeedbackDialog> createState() => _TripFeedbackDialogState();

  // Static method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required Function(double rating, String comment) onSubmit,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TripFeedbackDialog(onSubmit: onSubmit, onCancel: onCancel);
      },
    );
  }
}

class _TripFeedbackDialogState extends State<TripFeedbackDialog> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop();
  }

  void _handleSubmit() {
    if (_userRating > 0) {
      widget.onSubmit(_userRating, _commentController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.star_rate, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('Trip Feedback'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How would you rate your overall trip experience?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Center(
              child: RatingBar.builder(
                initialRating: _userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemBuilder:
                    (context, _) => const Icon(
                      Icons.star,
                      color:
                          AppTheme
                              .whiteColor, // Changed from whiteColor to primaryColor for better visibility
                    ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _userRating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional comments (optional):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              cursorColor: AppTheme.whiteColor,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText:
                    'Share your experience, suggestions, or any feedback...',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(onPressed: _handleCancel, child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: _userRating > 0 ? _handleSubmit : null,
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
