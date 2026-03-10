// lib/data/models/incident_model.dart

import 'dart:convert';

import 'package:arcon_travel_app/data/models/location_model.dart';

class IncidentModel {
  final String id;
  final String customer;
  final String title;
  final List<String> incidentPhotos;
  final String notes;
  final DateTime incidentDate;
  final LocationModel incidentLocation;
  final String incidentTime;
  final String incidentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int incidentId;

  IncidentModel({
    required this.id,
    required this.customer,
    required this.title,
    required this.incidentPhotos,
    required this.notes,
    required this.incidentDate,
    required this.incidentLocation,
    required this.incidentTime,
    required this.incidentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.incidentId,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'customer': customer,
      'title': title,
      'incidentPhotos': incidentPhotos,
      'notes': notes,
      'incidentDate': incidentDate.toIso8601String(),
      'incidentLocation': incidentLocation,
      'incidentTime': incidentTime,
      'incidentStatus': incidentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'incidentId': incidentId,
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      id: map['_id'] ?? '',
      customer: map['customer'] ?? '',
      title: map['title'] ?? '',
      incidentPhotos: List<String>.from(map['incidentPhotos'] ?? []),
      notes: map['notes'] ?? '',
      incidentDate: DateTime.parse(map['incidentDate']),
      incidentLocation: LocationModel.fromJson(map['incidentLocation'] ?? {}),
      incidentTime: map['incidentTime'] ?? '',
      incidentStatus: map['incidentStatus'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      incidentId: map['incidentId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory IncidentModel.fromJson(Map<String, dynamic> source) =>
      IncidentModel.fromMap(source);

  IncidentModel copyWith({
    String? id,
    String? customer,
    List<String>? incidentPhotos,
    String? notes,
    DateTime? incidentDate,
    LocationModel? incidentLocation,
    String? incidentTime,
    String? incidentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? incidentId,
    String? title,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      customer: customer ?? this.customer,
      incidentPhotos: incidentPhotos ?? this.incidentPhotos,
      notes: notes ?? this.notes,
      incidentDate: incidentDate ?? this.incidentDate,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      incidentTime: incidentTime ?? this.incidentTime,
      incidentStatus: incidentStatus ?? this.incidentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      incidentId: incidentId ?? this.incidentId,
    );
  }

  @override
  String toString() {
    return 'IncidentModel(id: $id, title: $title, customer: $customer, incidentPhotos: $incidentPhotos, notes: $notes, incidentDate: $incidentDate, incidentLocation: $incidentLocation, incidentTime: $incidentTime, incidentStatus: $incidentStatus, createdAt: $createdAt, updatedAt: $updatedAt, incidentId: $incidentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IncidentModel &&
        other.id == id &&
        other.customer == customer &&
        listEquals(other.incidentPhotos, incidentPhotos) &&
        other.notes == notes &&
        other.incidentDate == incidentDate &&
        other.incidentLocation == incidentLocation &&
        other.incidentTime == incidentTime &&
        other.incidentStatus == incidentStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.incidentId == incidentId &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customer.hashCode ^
        incidentPhotos.hashCode ^
        notes.hashCode ^
        incidentDate.hashCode ^
        incidentLocation.hashCode ^
        incidentTime.hashCode ^
        incidentStatus.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        incidentId.hashCode ^
        title.hashCode;
  }
}

// Helper function for list comparison in equality operator
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
