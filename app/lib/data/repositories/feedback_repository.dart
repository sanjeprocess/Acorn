import 'package:arcon_travel_app/data/models/feedback_model.dart';
import 'package:arcon_travel_app/data/services/feedback_service.dart';

/// Repository that handles authentication use cases
class FeedbackRepository {
  final FeedbackService _feedbackService;

  FeedbackRepository(this._feedbackService);

  Future<void> createFeedback({
    required String customerId,
    required String travelId,
    required double rating,
    required String feedback,
  }) async {
    return await _feedbackService.createFeedback(
      customerId: customerId,
      travelId: travelId,
      rating: rating,
      feedback: feedback,
    );
  }

  Future<List<FeedbackModel>> getUserAllFeedback(String userId) async {
    return await _feedbackService.getUserAllFeedback(userId);
  }

  Future<FeedbackModel?> getFeedbackByTravelId(String travelId) async {
    return await _feedbackService.getFeedbackbyTravelId(travelId);
  }
}
