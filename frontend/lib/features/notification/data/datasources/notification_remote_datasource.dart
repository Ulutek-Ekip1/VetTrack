import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/notification/data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getNotifications(
      {int page = 0, int size = 20});
  Future<void> registerDeviceToken(
      {required String fcmToken, String platform = 'android'});
  Future<void> unregisterDeviceToken({required String fcmToken});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationEntity>> getNotifications(
      {int page = 0, int size = 20}) async {
    try {
      final response = await dio.get(
        '/notifications',
        queryParameters: {'page': page, 'size': size},
      );
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List contentList = data['content'] as List? ?? [];
      return contentList
          .map((json) =>
              NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
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
}
