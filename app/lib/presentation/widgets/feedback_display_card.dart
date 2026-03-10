import 'package:arcon_travel_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feedback_entity.dart';

class FeedbackDisplayCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final VoidCallback? onTap;
  final double elevation;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? primaryColor;
  final Color? secondaryColor;

  const FeedbackDisplayCard({
    super.key,
    required this.feedback,
    this.onTap,
    this.elevation = 2,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = this.primaryColor ?? AppTheme.primaryColor;
    final secondaryColor = this.secondaryColor ?? AppTheme.primaryColor;

    return Card(
      color: AppTheme.whiteColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, primaryColor),
              const SizedBox(height: 16),
              _buildRatingSection(context, primaryColor, secondaryColor),
              const SizedBox(height: 16),
              _buildCommentsSection(context, primaryColor, secondaryColor),
              const SizedBox(height: 12),
              _buildTimestamp(context, secondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Icon(Icons.feedback, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          'Your Feedback',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Row(
      children: [
        Text(
          'Rating: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: secondaryColor,
          ),
        ),
        RatingBarIndicator(
          rating: feedback.rating,
          itemBuilder: (context, _) => Icon(Icons.star, color: primaryColor),
          itemCount: 5,
          itemSize: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '(${feedback.rating.toStringAsFixed(1)})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.1)),
          ),
          child: Text(
            feedback.feedback.isNotEmpty
                ? feedback.feedback
                : 'No comments provided',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle:
                  feedback.feedback.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
              color: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context, Color secondaryColor) {
    return Text(
      'Submitted on ${DateFormat('dd MMM yyyy, hh:mm a').format(feedback.createdAt)}',
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: secondaryColor),
    );
  }
}
