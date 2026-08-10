import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:vettrack_frontend/core/services/top_notification.dart';
import '../../features/notification/domain/usecases/unregister_device_token_usecase.dart';
import '../di/injection_container.dart';
import '../../features/notification/domain/usecases/register_device_token_usecase.dart';
import '../../features/notification/domain/usecases/mark_as_read_usecase.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Arka planda bildirim geldi: ${message.messageId}");
}

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> sendTokenToBackend() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final registerTokenUseCase = sl<RegisterDeviceTokenUseCase>();
      final platform =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await registerTokenUseCase(fcmToken: token, platform: platform);
    }
  }

  Future<void> removeTokenFromBackend() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final unregisterTokenUseCase = sl<UnregisterDeviceTokenUseCase>();
      await unregisterTokenUseCase(fcmToken: token);
    }
  }

  Future<void> initNotifications() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _setupForegroundListener();
    } else {}
  }

  void _handleNotificationClick(RemoteMessage message) {
    final notificationId = message.data['notificationId'];
    if (notificationId != null) {
      final markAsRead = sl<MarkAsReadUseCase>();
      markAsRead(notificationId.toString());
    }
    // Yönlendirme yapılabilir
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title'] ??
          message.notification?.title ??
          'Yeni Bildirim';
      final body = message.data['body'] ?? message.notification?.body ?? '';
      final type = message.data['type'];
      final notificationId = message.data['notificationId'];

      TopNotification.show(
          title: title,
          body: body,
          type: type,
          onTap: () {
            if (notificationId != null) {
              final markAsRead = sl<MarkAsReadUseCase>();
              markAsRead(notificationId.toString());
            }
            // Yönlendirme yapılabilir
          });
    });
  }

  void listenForTokenChanges() {
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        final registerToken = sl<RegisterDeviceTokenUseCase>();
        final platform =
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
        await registerToken(fcmToken: newToken, platform: platform);
      },
    ).onError(
      (err) {},
    );
  }
}
