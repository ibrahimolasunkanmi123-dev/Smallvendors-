class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    this.location,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profilePicture': profilePicture,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': createdAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    profilePicture: json['profilePicture'],
    location: json['location'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}