class Product {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imagePath;
  final bool isAvailable;
  final int stock;
  final int minStock;
  final int views;
  final int orders;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imagePath,
    this.isAvailable = true,
    this.stock = 0,
    this.minStock = 5,
    this.views = 0,
    this.orders = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    String? vendorId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imagePath,
    bool? isAvailable,
    int? stock,
    int? minStock,
    int? views,
    int? orders,
    DateTime? updatedAt,
  }) => Product(
    id: id,
    vendorId: vendorId ?? this.vendorId,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    category: category ?? this.category,
    imagePath: imagePath ?? this.imagePath,
    isAvailable: isAvailable ?? this.isAvailable,
    stock: stock ?? this.stock,
    minStock: minStock ?? this.minStock,
    views: views ?? this.views,
    orders: orders ?? this.orders,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendorId': vendorId,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imagePath': imagePath,
    'isAvailable': isAvailable,
    'stock': stock,
    'minStock': minStock,
    'views': views,
    'orders': orders,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    vendorId: json['vendorId'] ?? '',
    name: json['name'],
    description: json['description'],
    price: json['price'].toDouble(),
    category: json['category'],
    imagePath: json['imagePath'],
    isAvailable: json['isAvailable'] ?? true,
    stock: json['stock'] ?? 0,
    minStock: json['minStock'] ?? 5,
    views: json['views'] ?? 0,
    orders: json['orders'] ?? 0,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );
}