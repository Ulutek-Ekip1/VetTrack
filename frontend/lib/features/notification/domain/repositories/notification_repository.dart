import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListEntity> getNotifications();
  Future<void> registerDeviceToken({required String fcmToken, String platform});
  Future<void> unregisterDeviceToken({required String fcmToken});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
