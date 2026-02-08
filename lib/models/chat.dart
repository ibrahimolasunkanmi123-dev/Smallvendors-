import 'package:uuid/uuid.dart';

class Chat {
  final String id;
  final String vendorId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String vendorName;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  Chat({
    String? id,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.vendorName = 'Vendor',
    this.lastMessage,
    DateTime? lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       lastMessageTime = lastMessageTime ?? DateTime.now();

  Chat copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
  }) => Chat(
    id: id,
    vendorId: vendorId,
    customerId: customerId,
    customerName: customerName,
    customerPhone: customerPhone,
    vendorName: vendorName,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    isActive: isActive ?? this.isActive,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendorId': vendorId,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'vendorName': vendorName,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
    'isActive': isActive,
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    vendorId: json['vendorId'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    vendorName: json['vendorName'] ?? 'Vendor',
    lastMessage: json['lastMessage'],
    lastMessageTime: DateTime.parse(json['lastMessageTime']),
    unreadCount: json['unreadCount'] ?? 0,
    isActive: json['isActive'] ?? true,
  );
}