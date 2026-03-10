import 'dart:developer';
import 'dart:io';

import 'package:arcon_travel_app/data/models/location_model.dart';
import 'package:dio/dio.dart';

import '../models/incident_model.dart';
import 'api_service.dart';
import '../../core/constants/api_constant.dart';

/// Service responsible for incident-related API operations
class IncidentService {
  final ApiService _apiService;

  /// Initialize with required ApiService
  IncidentService({required ApiService apiService}) : _apiService = apiService;

  /// Create a new incident report
  Future<void> createIncident({
    required String title,
    required String customer,
    required LocationModel incidentLocation,
    required String notes,
    required List<File> incidentPhotos,
  }) async {
    try {
      List<MultipartFile> photoFiles = [];
      for (File file in incidentPhotos) {
        String mimeType = 'application/octet-stream';
        String extension = file.path.split('.').last.toLowerCase();
        if (extension == 'jpg' || extension == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        } else if (extension == 'heic' || extension == 'heif') {
          mimeType = 'image/heic';
        }
        photoFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
            contentType: DioMediaType.parse(mimeType),
          ),
        );
      }

      // Then create the FormData with all fields
      final formData = FormData.fromMap({
        'title': title,
        'customer': customer,
        'incidentLocation': incidentLocation.toJson(),
        'notes': notes,
        'incidentPhotos': photoFiles,
      });

      // Make the API request
      final response = await _apiService.post(
        ApiConstants.incidents,
        data: formData,
      );

      // Parse the response data into an Incident model
      //return IncidentModel.fromJson(response.data['incident']);
    } catch (e) {
      rethrow;
    }
    return;
  }

  /// Get all incidents for a user
  Future<List<IncidentModel>> getUserIncidents(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.incidents}/$userId',
      );

      final List<dynamic> incidentsData = response.data['data']['incidents'];
      List<IncidentModel> incidents =
          incidentsData.map((data) => IncidentModel.fromJson(data)).toList();

      log(incidents.toString());
      return incidents;
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific incident by ID
  Future<IncidentModel> getIncidentById(String incidentId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.incidents}/$incidentId',
      );

      return IncidentModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing incident
  Future<IncidentModel> updateIncident({
    required String incidentId,
    String? customer,
    String? incidentLocation,
    String? notes,
    List<String>? incidentPhotos,
  }) async {
    try {
      // Build update data with only non-null fields
      final Map<String, dynamic> updateData = {};
      if (customer != null) updateData['customer'] = customer;
      if (incidentLocation != null)
        updateData['incidentLocation'] = incidentLocation;
      if (notes != null) updateData['notes'] = notes;
      if (incidentPhotos != null) updateData['incidentPhotos'] = incidentPhotos;

      final response = await _apiService.put(
        '${ApiConstants.incidents}/$incidentId',
        data: updateData,
      );

      return IncidentModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an incident
  Future<bool> deleteIncident(String incidentId) async {
    try {
      await _apiService.delete('${ApiConstants.incidents}/$incidentId');

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
