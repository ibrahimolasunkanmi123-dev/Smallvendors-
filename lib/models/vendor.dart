class Vendor {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String businessType;
  final String? location;
  final String? logoPath;
  final double rating;
  final int totalReviews;
  final int totalTransactions;
  final String? whatsapp;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final String? twitter;
  final String? email;

  Vendor({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    this.businessType = '',
    this.location,
    this.logoPath,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalTransactions = 0,
    this.whatsapp,
    this.telegram,
    this.instagram,
    this.facebook,
    this.twitter,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessName': businessName,
    'ownerName': ownerName,
    'phone': phone,
    'businessType': businessType,
    'location': location,
    'logoPath': logoPath,
    'rating': rating,
    'totalReviews': totalReviews,
    'totalTransactions': totalTransactions,
    'whatsapp': whatsapp,
    'telegram': telegram,
    'instagram': instagram,
    'facebook': facebook,
    'twitter': twitter,
    'email': email,
  };

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json['id'],
    businessName: json['businessName'],
    ownerName: json['ownerName'],
    phone: json['phone'],
    businessType: json['businessType'] ?? '',
    location: json['location'],
    logoPath: json['logoPath'],
    rating: json['rating']?.toDouble() ?? 0.0,
    totalReviews: json['totalReviews'] ?? 0,
    totalTransactions: json['totalTransactions'] ?? 0,
    whatsapp: json['whatsapp'],
    telegram: json['telegram'],
    instagram: json['instagram'],
    facebook: json['facebook'],
    twitter: json['twitter'],
    email: json['email'],
  );
}