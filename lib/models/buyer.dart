class Buyer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? profileImage;
  final String? location;
  final DateTime createdAt;

  Buyer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'profileImage': profileImage,
    'location': location,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'],
    profileImage: json['profileImage'],
    location: json['location'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Buyer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? location,
    DateTime? createdAt,
  }) => Buyer(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    profileImage: profileImage ?? this.profileImage,
    location: location ?? this.location,
    createdAt: createdAt ?? this.createdAt,
  );
}