
import '../models/notification.dart';


class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();


  final Map<String, List<AppNotification>> _cache = {};

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? actionData,
    NotificationType type = NotificationType.general,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      message: message,
      type: type,
      actionData: actionData,
    );

    final notifications = await getNotifications(userId);
    notifications.insert(0, notification);
    _cache[userId] = notifications;
  }

  Future<List<AppNotification>> getNotifications(String userId) async {
    return _cache[userId] ?? [];
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    final notifications = await getNotifications(userId);
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _cache[userId] = notifications;
    }
  }

  Future<int> getUnreadCount(String userId) async {
    final notifications = await getNotifications(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  // Send order notifications
  Future<void> sendOrderNotification(String vendorId, String orderId, String customerName) async {
    await sendNotification(
      userId: vendorId,
      title: 'New Order Received!',
      message: 'You have a new order from $customerName',
      type: NotificationType.order,
      actionData: orderId,
    );
  }

  // Send low stock notifications
  Future<void> sendLowStockNotification(String vendorId, String productName) async {
    await sendNotification(
      userId: vendorId,
      title: 'Low Stock Alert',
      message: '$productName is running low on stock',
      type: NotificationType.inventory,
    );
  }

  // Send promotional notifications
  Future<void> sendPromotionalNotification(String userId, String title, String message) async {
    await sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.promotional,
    );
  }
}