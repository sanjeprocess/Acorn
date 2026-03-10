class FeedbackEntity {
  final int feedbackId;
  final String travelId;
  final double rating;
  final String feedback;
  final DateTime createdAt;

  FeedbackEntity({
    required this.feedbackId,
    required this.travelId,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });
}
