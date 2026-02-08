import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime lastOrderAt;
  final int totalOrders;
  final double totalSpent;
  final double rating;
  final int totalReviews;

  Customer({
    String? id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    DateTime? createdAt,
    DateTime? lastOrderAt,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.rating = 0.0,
    this.totalReviews = 0,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       lastOrderAt = lastOrderAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'createdAt': createdAt.toIso8601String(),
    'lastOrderAt': lastOrderAt.toIso8601String(),
    'totalOrders': totalOrders,
    'totalSpent': totalSpent,
    'rating': rating,
    'totalReviews': totalReviews,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    address: json['address'],
    createdAt: DateTime.parse(json['createdAt']),
    lastOrderAt: json['lastOrderAt'] != null ? DateTime.parse(json['lastOrderAt']) : DateTime.now(),
    totalOrders: json['totalOrders'] ?? 0,
    totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
    rating: json['rating']?.toDouble() ?? 0.0,
    totalReviews: json['totalReviews'] ?? 0,
  );
}