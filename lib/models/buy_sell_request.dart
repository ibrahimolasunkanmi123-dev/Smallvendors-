enum RequestType { buy, sell }

enum RequestStatus { active, completed, cancelled }

class BuySellRequest {
  final String id;
  final String userId;
  final String userName;
  final RequestType type;
  final String title;
  final String description;
  final String category;
  final double? price;
  final String? location;
  final String? imagePath;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> tags;

  BuySellRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    this.price,
    this.location,
    this.imagePath,
    this.status = RequestStatus.active,
    DateTime? createdAt,
    this.expiresAt,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isBuyRequest => type == RequestType.buy;
  bool get isSellRequest => type == RequestType.sell;

  BuySellRequest copyWith({
    String? userId,
    String? userName,
    RequestType? type,
    String? title,
    String? description,
    String? category,
    double? price,
    String? location,
    String? imagePath,
    RequestStatus? status,
    DateTime? expiresAt,
    List<String>? tags,
  }) => BuySellRequest(
    id: id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    price: price ?? this.price,
    location: location ?? this.location,
    imagePath: imagePath ?? this.imagePath,
    status: status ?? this.status,
    createdAt: createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    tags: tags ?? this.tags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'type': type.name,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'location': location,
    'imagePath': imagePath,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'tags': tags,
  };

  factory BuySellRequest.fromJson(Map<String, dynamic> json) => BuySellRequest(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    type: RequestType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'],
    description: json['description'],
    category: json['category'],
    price: json['price']?.toDouble(),
    location: json['location'],
    imagePath: json['imagePath'],
    status: RequestStatus.values.firstWhere((e) => e.name == json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    tags: List<String>.from(json['tags'] ?? []),
  );
}