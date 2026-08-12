import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/core/services/top_notification.dart';
import '../../features/notification/domain/usecases/unregister_device_token_usecase.dart';
import '../di/injection_container.dart';
import '../../features/notification/domain/usecases/register_device_token_usecase.dart';
import '../../features/notification/domain/usecases/mark_as_read_usecase.dart';
import '../router/app_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Arka planda bildirim geldi: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _tokenRefreshListening = false;

  Future<void> sendTokenToBackend() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await sl<RegisterDeviceTokenUseCase>()(
      fcmToken: token,
      platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    );
  }

  Future<void> removeTokenFromBackend() async {
    final token = await _messaging.getToken();
    if (token != null) await sl<UnregisterDeviceTokenUseCase>()(fcmToken: token);
  }

  Future<void> initNotifications() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    final message = await _messaging.getInitialMessage();
    if (message != null) _handleNotificationClick(message);
    _setupForegroundListener();
  }

  Future<AuthorizationStatus> requestPermissionFromUser() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final status = settings.authorizationStatus;
    if (status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional) {
      await sendTokenToBackend();
      listenForTokenChanges();
    }
    return status;
  }

  void _handleNotificationClick(RemoteMessage message) {
    final notificationId = message.data['notificationId'];
    if (notificationId != null) sl<MarkAsReadUseCase>()(notificationId.toString());
    _navigateToPetTimeline(message.data);
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.data['title'] ?? message.notification?.title ?? 'Yeni Bildirim';
      final body = message.data['body'] ?? message.notification?.body ?? '';
      TopNotification.show(
        title: title,
        body: body,
        type: message.data['type'] ?? 'SYSTEM',
        onTap: () => _handleNotificationClick(message),
      );
    });
  }

  void listenForTokenChanges() {
    if (_tokenRefreshListening) return;
    _tokenRefreshListening = true;
    _messaging.onTokenRefresh.listen((newToken) async {
      await sl<RegisterDeviceTokenUseCase>()(
        fcmToken: newToken,
        platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      );
    });
  }

  void _navigateToPetTimeline(Map<String, dynamic> data) {
    final petId = data['petId']?.toString();
    final context = AppRouter.navigatorKey.currentContext;
    if (petId != null && petId.isNotEmpty && context != null) {
      context.push('/owner/pets/$petId/treatments');
    }
  }
}
