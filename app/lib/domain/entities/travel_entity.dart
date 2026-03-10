// lib/domain/entities/travel_entity.dart
import 'package:arcon_travel_app/data/models/travel_model.dart';

class TravelEntity {
  final String id;
  final String customer;
  final String startingLocation;
  final String destination;
  final TravelStatus travelStatus;
  final List<String>? hotels;
  final List<String>? flights;
  final List<String>? tourItineraries;
  final List<String>? transfers;
  final List<String>? cruiseDocs;
  final List<String>? vehicles;
  final List<String>? otherCsaDocs;
  final String? travelDate;
  final DateTime createdAt;
  final Map? otherDocs;
  final int travelId;

  TravelEntity({
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
    this.otherDocs,
    this.otherCsaDocs,
    this.travelDate,
    required this.createdAt,
    required this.travelId,
  });

  // Create entity from model
  factory TravelEntity.fromModel(TravelModel model) {
    return TravelEntity(
      id: model.id,
      customer: model.customer,
      startingLocation: model.startingLocation,
      destination: model.destination,
      travelStatus: model.travelStatus,
      hotels: model.hotels,
      flights: model.flights,
      vehicles: model.vehicles,
      otherCsaDocs: model.otherCsaDocs,
      tourItineraries: model.tourItineraries,
      transfers: model.transfers,
      otherDocs: model.otherdocs,
      cruiseDocs: model.cruiseDocs,
      createdAt: model.createdAt,
      travelId: model.travelId,
      travelDate: model.travelDate,
    );
  }

  // Get a copy with updated fields
  TravelEntity copyWith({
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
    List<String>? otherCsaDOcs,
    DateTime? createdAt,
    int? travelId,
  }) {
    return TravelEntity(
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
      otherCsaDocs: otherCsaDOcs ?? otherCsaDOcs,
      createdAt: createdAt ?? this.createdAt,
      travelId: travelId ?? this.travelId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TravelEntity &&
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

  @override
  String toString() {
    return 'TravelEntity(id: $id, travelId: $travelId, customer: $customer, '
        'startingLocation: $startingLocation, destination: $destination, '
        'travelStatus: $travelStatus, createdAt: $createdAt)';
  }
}
