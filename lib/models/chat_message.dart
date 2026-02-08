import 'package:uuid/uuid.dart';

enum MessageType { text, image, product, payment, paymentRequest }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final String? productId;
  final String? imagePath;
  final double? amount;
  final String? paymentStatus;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    String? id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    this.productId,
    this.imagePath,
    this.amount,
    this.paymentStatus,
    DateTime? timestamp,
    this.isRead = false,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? content,
    MessageType? type,
    String? productId,
    String? imagePath,
    double? amount,
    String? paymentStatus,
    bool? isRead,
  }) => ChatMessage(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    content: content ?? this.content,
    type: type ?? this.type,
    productId: productId ?? this.productId,
    imagePath: imagePath ?? this.imagePath,
    amount: amount ?? this.amount,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'type': type.name,
    'productId': productId,
    'imagePath': imagePath,
    'amount': amount,
    'paymentStatus': paymentStatus,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    chatId: json['chatId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    content: json['content'],
    type: MessageType.values.firstWhere((e) => e.name == json['type']),
    productId: json['productId'],
    imagePath: json['imagePath'],
    amount: json['amount']?.toDouble(),
    paymentStatus: json['paymentStatus'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );
}