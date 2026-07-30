import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> registerDeviceToken({required String fcmToken, String platform});
}
