import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vettrack_frontend/core/services/top_notification.dart';
import '../../features/notification/domain/usecases/unregister_device_token_usecase.dart';
import '../di/injection_container.dart';
import '../../features/notification/domain/usecases/register_device_token_usecase.dart';

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
      await registerTokenUseCase(fcmToken: token, platform: 'android');
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
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Kullanıcı bildirim izni verdi.');
      final testToken =
          await _messaging.getToken(); // geçici sunucu bağlanınca sil
      debugPrint(
          '======================================='); //geçici sunucu bağlanınca sil
      debugPrint(
          'BENİM TEST TOKENIM: $testToken'); //  geçici sunucu bağlanınca sil
      debugPrint(
          '======================================='); // geçici sunucu bağlanınca sil
      _setupForegroundListener();
    } else {
      debugPrint('Kullanıcı bildirim iznini reddetti.');
    }
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Uygulama açıkken bildirim geldi!');

      final title = message.notification?.title ?? 'Yeni Bildirim';
      final body = message.notification?.body ?? '';

      TopNotification.show(
        title: title,
        body: body,
      );
    });
  }

  void listenForTokenChanges() {
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        final registerToken = sl<RegisterDeviceTokenUseCase>();
        await registerToken(fcmToken: newToken, platform: 'android');
      },
    ).onError(
      (err) {},
    );
  }
}
