class LocationModel {
  final double longitude;
  final double latitude;

  /// Creates a new [LocationModel].
  ///
  /// The [longitude] and [latitude] parameters are required.
  const LocationModel({required this.longitude, required this.latitude});

  /// Creates a [LocationModel] from a JSON map.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      longitude: json['longitude'].toDouble() ?? 0.00,
      latitude: json['latitude'].toDouble() ?? 0.00,
    );
  }

  /// Converts this [LocationModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {'longitude': longitude, 'latitude': latitude};
  }

  /// Creates a copy of this [LocationModel] with the specified fields replaced.
  LocationModel copyWith({double? longitude, double? latitude}) {
    return LocationModel(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }

  /// Returns a string representation of this location.
  @override
  String toString() {
    return 'LocationModel(longitude: $longitude, latitude: $latitude)';
  }

  /// Compares this location with another location for equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationModel &&
        other.longitude == longitude &&
        other.latitude == latitude;
  }

  /// Returns a hash code for this location.
  @override
  int get hashCode {
    return longitude.hashCode ^ latitude.hashCode;
  }
}
