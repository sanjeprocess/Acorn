import 'dart:developer';

import 'package:arcon_travel_app/data/models/feedback_model.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../core/constants/api_constant.dart';

/// Service responsible for incident-related API operations
class FeedbackService {
  final ApiService _apiService;

  /// Initialize with required ApiService
  FeedbackService({required ApiService apiService}) : _apiService = apiService;

  /// Create a new Feedback
  Future<void> createFeedback({
    required String customerId,
    required String travelId,
    required double rating,
    required String feedback,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.feedback,
        data: {
          "customerId": customerId,
          "travelId": travelId,
          "rating": rating,
          "feedback": feedback,
        },
      );

      debugPrint('${response.data}');
    } catch (e) {
      rethrow;
    }
  }

  /// Get all Feedback for a user
  Future<List<FeedbackModel>> getUserAllFeedback(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.userFeedback}/$userId',
      );

      final List<dynamic> feedbackData = response.data['data']['feedbacks'];
      List<FeedbackModel> feedbacks =
          feedbackData.map((data) => FeedbackModel.fromJson(data)).toList();
      return feedbacks;
    } catch (e) {
      rethrow;
    }
  }

  /// Get Feedback by Travel id
  Future<FeedbackModel?> getFeedbackbyTravelId(String travelId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.travelFeedback}/$travelId',
      );
      log('response : ${response.data}');
      final dynamic data = response.data;
      final dynamic dataSection =
          data is Map<String, dynamic> ? data['data'] : null;
      final dynamic feedbackPayload =
          dataSection is Map<String, dynamic>
              ? dataSection['feedbacks'] ?? dataSection['feedback']
              : null;

      if (feedbackPayload == null) {
        return null;
      }

      if (feedbackPayload is Map<String, dynamic>) {
        return FeedbackModel.fromJson(feedbackPayload);
      }

      if (feedbackPayload is List && feedbackPayload.isNotEmpty) {
        final dynamic first = feedbackPayload.first;
        if (first is Map<String, dynamic>) {
          return FeedbackModel.fromJson(first);
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
