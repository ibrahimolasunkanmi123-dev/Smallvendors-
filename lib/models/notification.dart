enum NotificationType { order, inventory, promotional, general, payment }

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionData;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.actionData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'actionData': actionData,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    message: json['message'],
    type: NotificationType.values.firstWhere((e) => e.name == json['type']),
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
    actionData: json['actionData'],
  );

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? actionData,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    message: message ?? this.message,
    type: type ?? this.type,
    timestamp: timestamp ?? this.timestamp,
    isRead: isRead ?? this.isRead,
    actionData: actionData ?? this.actionData,
  );
}