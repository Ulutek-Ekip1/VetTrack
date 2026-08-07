import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/notification/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListModel> getNotifications({int page = 0, int size = 20});
  Future<void> registerDeviceToken(
      {required String fcmToken, String platform = 'android'});
  Future<void> unregisterDeviceToken({required String fcmToken});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<NotificationListModel> getNotifications(
      {int page = 0, int size = 20}) async {
    try {
      final response = await dio.get(
        '/notifications',
        queryParameters: {'page': page, 'size': size},
      );
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return NotificationListModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Bildirimler alınamadı.');
    }
  }

  @override
  Future<void> registerDeviceToken(
      {required String fcmToken, String platform = 'android'}) async {
    try {
      await dio.post(
        '/devices/register',
        data: {
          'fcmToken': fcmToken,
          'platform': platform,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Cihaz tokenı kaydedilemedi.');
    }
  }

  @override
  Future<void> unregisterDeviceToken({required String fcmToken}) async {
    try {
      await dio.post(
        '/devices/unregister',
        data: {
          'fcmToken': fcmToken,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Cihaz tokenı silinemedi.');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('/notifications/unread-count');
      final data = response.data as Map<String, dynamic>;
      return data['unreadCount'] as int? ?? 0;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Okunmamış sayı alınamadı.');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Bildirim okundu işaretlenemedi.');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Bildirimler okundu işaretlenemedi.');
    }
  }
}
