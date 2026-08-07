import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<NotificationListEntity> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<void> registerDeviceToken({required String fcmToken, String platform = 'android'}) async {
    await remoteDataSource.registerDeviceToken(fcmToken: fcmToken, platform: platform);
  }

  @override
  Future<void> unregisterDeviceToken({required String fcmToken}) async {
    await remoteDataSource.unregisterDeviceToken(fcmToken: fcmToken);
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(String id) async {
    await remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDataSource.markAllAsRead();
  }
}
