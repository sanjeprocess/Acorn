import 'package:arcon_travel_app/data/models/travel_model.dart';
import 'package:arcon_travel_app/data/services/travel_service.dart';

/// Repository that handles authentication use cases
class TravelsRepository {
  final TravelService _travelService;

  TravelsRepository(this._travelService);

  Future<List<TravelModel>> getUserTavelData(String userId) async {
    return await _travelService.getUserTravels(userId);
  }

  Future<bool> updateTravelToComplete(int travelId) async {
    return await _travelService.updateTravelToComplete(travelId);
  }
}
