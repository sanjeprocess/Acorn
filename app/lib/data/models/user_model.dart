/// User model representing authenticated user data
class UserModel {
  final String id;
  final String name;
  final String email;
  final Map<String, dynamic> csa;

  /// Constructor with named parameters
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.csa,
  });

  /// Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['customerId'].toString(),
      name: json['name'],
      email: json['email'],
      csa: json['csa'],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': id,
      'name': name,
      'email': email,
      'csa': csa,

      // Only include these fields if they're not null
    };
  }

  /// Create a copy of UserModel with optional updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    Map<String, dynamic>? csa,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      csa: csa ?? this.csa,
    );
  }
}
