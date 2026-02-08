import 'cart_item.dart';

class Order {
  final String id;
  final String buyerId;
  final String vendorId;
  final List<CartItem> items;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.notes,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'buyerId': buyerId,
    'vendorId': vendorId,
    'items': items.map((item) => item.toJson()).toList(),
    'status': status,
    'totalAmount': totalAmount,
    'orderDate': orderDate.toIso8601String(),
    'deliveryAddress': deliveryAddress,
    'paymentMethod': paymentMethod,
    'notes': notes,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    buyerId: json['buyerId'],
    vendorId: json['vendorId'],
    items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
    status: json['status'],
    totalAmount: json['totalAmount'].toDouble(),
    orderDate: DateTime.parse(json['orderDate']),
    deliveryAddress: json['deliveryAddress'],
    paymentMethod: json['paymentMethod'],
    notes: json['notes'],
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );

  Order copyWith({
    String? id,
    String? buyerId,
    String? vendorId,
    List<CartItem>? items,
    String? status,
    double? totalAmount,
    DateTime? orderDate,
    String? deliveryAddress,
    String? paymentMethod,
    String? notes,
    DateTime? completedAt,
  }) => Order(
    id: id ?? this.id,
    buyerId: buyerId ?? this.buyerId,
    vendorId: vendorId ?? this.vendorId,
    items: items ?? this.items,
    status: status ?? this.status,
    totalAmount: totalAmount ?? this.totalAmount,
    orderDate: orderDate ?? this.orderDate,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes ?? this.notes,
    completedAt: completedAt ?? this.completedAt,
  );
}

// Order status constants
class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static List<String> get all => [pending, confirmed, preparing, ready, delivered, cancelled];
}