import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<void> registerDeviceToken({required String fcmToken, String platform = 'android'}) async {
    await remoteDataSource.registerDeviceToken(fcmToken: fcmToken, platform: platform);
  }
}
