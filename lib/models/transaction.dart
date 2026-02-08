import 'enums.dart';

class Transaction {
  final String id;
  final String vendorId;
  final String buyerId;
  final String buyerName;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final List<TransactionItem> items;
  final double totalAmount;
  final double? subtotal;
  final double? total;
  final PaymentMethod? paymentMethod;
  final DateTime createdAt;
  final TransactionStatus status;
  final String? notes;

  Transaction({
    required this.id,
    required this.vendorId,
    required this.buyerId,
    required this.buyerName,
    required this.totalAmount,
    required this.createdAt,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.items = const [],
    this.subtotal,
    this.total,
    this.paymentMethod,
    this.status = TransactionStatus.completed,
    this.notes,
  });

  Transaction copyWith({
    String? id,
    String? vendorId,
    String? buyerId,
    String? buyerName,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<TransactionItem>? items,
    double? totalAmount,
    double? subtotal,
    double? total,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    TransactionStatus? status,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendorId': vendorId,
    'buyerId': buyerId,
    'buyerName': buyerName,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'items': items.map((i) => i.toJson()).toList(),
    'totalAmount': totalAmount,
    'subtotal': subtotal,
    'total': total,
    'paymentMethod': paymentMethod?.name,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'notes': notes,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    vendorId: json['vendorId'],
    buyerId: json['buyerId'],
    buyerName: json['buyerName'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    items: (json['items'] as List? ?? []).map((i) => TransactionItem.fromJson(i)).toList(),
    totalAmount: json['totalAmount'].toDouble(),
    subtotal: json['subtotal']?.toDouble(),
    total: json['total']?.toDouble(),
    paymentMethod: json['paymentMethod'] != null ? PaymentMethod.values.byName(json['paymentMethod']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    status: json['status'] != null ? TransactionStatus.values.byName(json['status']) : TransactionStatus.completed,
    notes: json['notes'],
  );
}

class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  TransactionItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    price: json['price'].toDouble(),
  );
}
