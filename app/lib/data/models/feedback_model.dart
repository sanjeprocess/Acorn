class FeedbackModel {
  final int feedbackId;
  final String travelId;
  final double rating;
  final String feedback;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.travelId,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  // Factory constructor to create a FeedbackModel from JSON
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'],
      travelId: json['travelId'],
      rating: json['rating'].toDouble(),
      feedback: json['feedback'] ?? json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert FeedbackModel to JSON for API requests or local storage
  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'travelId': travelId,
      'rating': rating,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy of the feedback model with updated fields
  FeedbackModel copyWith({
    int? feedbackId,
    String? travelId,
    double? rating,
    String? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      travelId: travelId ?? this.travelId,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FeedbackModel(feedbackId: $feedbackId, travelId: $travelId, rating: $rating, feedback: $feedback, createdAt: $createdAt)';
  }
}
