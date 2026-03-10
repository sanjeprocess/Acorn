import 'dart:io';

import 'package:arcon_travel_app/data/models/incident_model.dart';
import 'package:arcon_travel_app/data/models/location_model.dart';
import 'package:arcon_travel_app/data/services/incident_service.dart';

/// Repository that handles authentication use cases
class IncidentRepository {
  final IncidentService _incidentService;

  IncidentRepository(this._incidentService);

  /// Login user with email and password
  Future<void> createIncident(
    String title,
    String customer,
    LocationModel incidentLocation,
    String notes,
    List<File> incidentPhotos,
  ) async {
    return await _incidentService.createIncident(
      title: title,
      customer: customer,
      incidentLocation: incidentLocation,
      notes: notes,
      incidentPhotos: incidentPhotos,
    );
  }

  Future<List<IncidentModel>> getUserIncidents(String userId) async {
    return await _incidentService.getUserIncidents(userId);
  }
}
