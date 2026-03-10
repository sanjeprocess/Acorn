import 'dart:developer' show log;

enum TravelStatus { ON_GOING, COMPLETED, CANCELLED }

class TravelModel {
  final String id;
  final String customer;
  final String startingLocation;
  final String destination;
  final String? travelDate;
  final TravelStatus travelStatus;
  final List<String>? hotels;
  final List<String>? flights;
  final List<String>? tourItineraries;
  final List<String>? transfers;
  final List<String>? cruiseDocs;
  final List<String>? otherCsaDocs;
  final List<String>? vehicles;
  final Map? otherdocs;

  final DateTime createdAt;
  final int travelId;

  TravelModel({
    required this.id,
    required this.customer,
    required this.startingLocation,
    required this.destination,
    required this.travelStatus,
    this.hotels,
    this.flights,
    this.vehicles,
    this.tourItineraries,
    this.transfers,
    this.cruiseDocs,
    this.otherdocs,
    this.otherCsaDocs,
    this.travelDate,
    required this.createdAt,
    required this.travelId,
  });

  // Create model from JSON
  factory TravelModel.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return TravelModel(
      id: json['_id'] ?? '',
      customer: json['customer'].toString() ?? '',
      startingLocation: json['startingLocation'] ?? '',
      destination: json['destination'] ?? '',
      travelStatus: _parseStatus(json['travelStatus']),
      hotels: (json['hotels'] ?? []).map<String>((e) => e.toString()).toList(),
      flights:
          (json['flights'] ?? []).map<String>((e) => e.toString()).toList(),
      vehicles:
          (json['vehicles'] ?? []).map<String>((e) => e.toString()).toList(),
      tourItineraries:
          (json['tourItineraries'] ?? [])
              .map<String>((e) => e.toString())
              .toList(),
      transfers:
          (json['transfers'] ?? []).map<String>((e) => e.toString()).toList(),
      cruiseDocs:
          (json['cruiseDocs'] ?? []).map<String>((e) => e.toString()).toList(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      travelId: json['travelId'] ?? 0,
      otherdocs: json['otherDocs'] ?? {},
      otherCsaDocs:
          (json['otherCSADocs'] ?? [])
              .map<String>((e) => e.toString())
              .toList(),
      travelDate: json['travelDate'] ?? "",
    );
  }

  // Convert model to JSON
  // Map<String, dynamic> toJson() {
  //   return {
  //     '_id': id,
  //     'customer': customer,
  //     'startingLocation': startingLocation,
  //     'destination': destination,
  //     'travelStatus': travelStatus.toString().split('.').last,
  //     'hotels': hotels,
  //     'flights': flights,
  //     'vehicles': vehicles,
  //     'createdAt': createdAt.toIso8601String(),
  //     'travelId': travelId,
  //   };
  // }

  // Convert the string status to enum
  static TravelStatus _parseStatus(String? status) {
    if (status == null) return TravelStatus.COMPLETED;

    switch (status.toUpperCase()) {
      case 'ON_GOING':
        return TravelStatus.ON_GOING;
      case 'CANCELLED':
        return TravelStatus.CANCELLED;
      case 'COMPLETED':
      default:
        return TravelStatus.COMPLETED;
    }
  }

  // Create a copy of the model with modified properties
  TravelModel copyWith({
    String? id,
    String? customer,
    String? startingLocation,
    String? destination,
    TravelStatus? travelStatus,
    List<String>? hotels,
    List<String>? flights,
    List<String>? vehicles,
    List<String>? tourItineraries,
    List<String>? transfers,
    List<String>? cruiseDocs,
    List<String>? otherCsaDocs,
    DateTime? createdAt,
    int? travelId,
  }) {
    return TravelModel(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      startingLocation: startingLocation ?? this.startingLocation,
      destination: destination ?? this.destination,
      travelStatus: travelStatus ?? this.travelStatus,
      hotels: hotels ?? this.hotels,
      flights: flights ?? this.flights,
      vehicles: vehicles ?? vehicles,
      tourItineraries: tourItineraries ?? tourItineraries,
      transfers: transfers ?? transfers,
      cruiseDocs: cruiseDocs ?? cruiseDocs,
      otherCsaDocs: otherCsaDocs ?? otherCsaDocs,
      createdAt: createdAt ?? this.createdAt,
      travelId: travelId ?? this.travelId,
    );
  }

  // For easy debugging
  @override
  String toString() {
    return 'TravelModel(id: $id, travelId: $travelId, customer: $customer, '
        'startingLocation: $startingLocation, destination: $destination, '
        'travelStatus: $travelStatus, '
        'createdAt: $createdAt)';
  }

  // For comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TravelModel &&
        other.id == id &&
        other.customer == customer &&
        other.startingLocation == startingLocation &&
        other.destination == destination &&
        other.travelStatus == travelStatus &&
        other.hotels == hotels &&
        other.flights == flights &&
        other.createdAt == createdAt &&
        other.travelId == travelId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customer.hashCode ^
        startingLocation.hashCode ^
        destination.hashCode ^
        travelStatus.hashCode ^
        hotels.hashCode ^
        flights.hashCode ^
        createdAt.hashCode ^
        travelId.hashCode;
  }
}
