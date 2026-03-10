import 'dart:developer';

import 'package:arcon_travel_app/data/models/travel_model.dart';
import 'api_service.dart';
import '../../core/constants/api_constant.dart';

/// Service responsible for incident-related API operations
class TravelService {
  final ApiService _apiService;

  /// Initialize with required ApiService
  TravelService({required ApiService apiService}) : _apiService = apiService;

  /// Create a new Travel report

  /// Get all Travels for a user
  Future<List<TravelModel>> getUserTravels(String userId) async {
    try {
      final response = await _apiService.get('${ApiConstants.travels}/$userId');

      final List<dynamic> travelData = response.data['data']['travels'];
      List<TravelModel> incidents =
          travelData.map((data) => TravelModel.fromJson(data)).toList();
      return incidents;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTravelToComplete(int travelId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.updateTravel,
        data: {'travelId': travelId.toString()},
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
