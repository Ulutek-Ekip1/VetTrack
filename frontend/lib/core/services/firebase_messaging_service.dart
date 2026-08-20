import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'vettrack_notifications',
    'VetTrack Bildirimleri',
    description: 'Muayene, tedavi ve hatırlatma bildirimleri',
    importance: Importance.high,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<void> _notificationEvents =
      StreamController<void>.broadcast();
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _tokenRefreshListening = false;
  bool _initialized = false;
  bool _disposed = false;
  String? _pendingPetTimelinePath;

  Stream<void> get notificationEvents => _notificationEvents.stream;

  String get _platform {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  Future<void> sendTokenToBackend() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _registerToken(token);
    } catch (error, stackTrace) {
      debugPrint('FCM token alınamadı: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> removeTokenFromBackend() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await sl<UnregisterDeviceTokenUseCase>()(fcmToken: token);
    }
  }

  Future<void> initNotifications() async {
    if (_disposed) {
      throw StateError('FirebaseMessagingService kapatıldıktan sonra başlatılamaz.');
    }
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _messageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    await _initializeLocalNotifications();
    final message = await _messaging.getInitialMessage();
    if (message != null) _handleNotificationClick(message);
    _setupForegroundListener();
  }

  Future<void> syncTokenIfAuthorized() async {
    final settings = await _messaging.getNotificationSettings();
    final status = settings.authorizationStatus;
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      await sendTokenToBackend();
      listenForTokenChanges();
    }
  }

  Future<AuthorizationStatus> requestPermissionFromUser() async {
    late final NotificationSettings settings;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();

      // Plugin kaydı beklenmedik biçimde bulunamazsa Firebase çağrısı güvenli
      // fallback olarak Android izin akışını denemeye devam eder.
      settings = granted == null
          ? await _messaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            )
          : await _messaging.getNotificationSettings();
    } else {
      settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final status = settings.authorizationStatus;
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      await sendTokenToBackend();
      listenForTokenChanges();
    }
    return status;
  }

  Future<bool> openNotificationSettings() async {
    if (kIsWeb) return false;
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      return true;
    } catch (_) {
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.settings);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final notificationId = data['notificationId'];
    if (notificationId != null) {
      sl<MarkAsReadUseCase>()(notificationId.toString());
    }
    _navigateToPetTimeline(data);
  }

  void _setupForegroundListener() {
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((message) {
      if (_disposed) return;
      final title = message.data['title'] ??
          message.notification?.title ??
          'Yeni Bildirim';
      final body = message.data['body'] ?? message.notification?.body ?? '';
      _notificationEvents.add(null);
      TopNotification.show(
        title: title,
        body: body,
        type: message.data['type'] ?? 'SYSTEM',
        onTap: () => _handleNotificationClick(message),
      );
      unawaited(_showForegroundSystemNotification(message, title, body));
    });
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_vettrack'),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _handleNotificationData(data);
        } catch (e) {
          debugPrint('Bildirim payload işlenemedi: $e');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _showForegroundSystemNotification(
    RemoteMessage message,
    String title,
    String body,
  ) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await _localNotifications.show(
      id: (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}')
              .hashCode &
          0x7fffffff,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vettrack_notifications',
          'VetTrack Bildirimleri',
          channelDescription: 'Muayene, tedavi ve hatırlatma bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_vettrack',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void listenForTokenChanges() {
    if (_disposed || _tokenRefreshListening) return;
    _tokenRefreshListening = true;
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (newToken) => unawaited(_registerToken(newToken)),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM token yenileme akışı hata verdi: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
      onDone: () {
        _tokenRefreshListening = false;
        _tokenRefreshSubscription = null;
      },
    );
  }

  Future<void> _registerToken(String token) async {
    try {
      await sl<RegisterDeviceTokenUseCase>()(
        fcmToken: token,
        platform: _platform,
      );
    } catch (error, stackTrace) {
      debugPrint('FCM token backend\'e kaydedilemedi: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _navigateToPetTimeline(Map<String, dynamic> data) {
    final petId = data['petId']?.toString();
    if (petId == null || petId.isEmpty) return;
    _pendingPetTimelinePath = '/owner/pets/$petId/treatments';
    flushPendingNavigation();
  }

  void flushPendingNavigation() {
    final path = _pendingPetTimelinePath;
    final context = AppRouter.navigatorKey.currentContext;
    if (path == null || context == null) return;

    _pendingPetTimelinePath = null;
    context.push(path);
  }

  Future<void> close() async {
    if (_disposed) return;
    _disposed = true;

    await Future.wait<void>([
      if (_foregroundMessageSubscription != null)
        _foregroundMessageSubscription!.cancel(),
      if (_messageOpenedAppSubscription != null)
        _messageOpenedAppSubscription!.cancel(),
      if (_tokenRefreshSubscription != null)
        _tokenRefreshSubscription!.cancel(),
    ]);

    _foregroundMessageSubscription = null;
    _messageOpenedAppSubscription = null;
    _tokenRefreshSubscription = null;
    _tokenRefreshListening = false;
    await _notificationEvents.close();
  }
}
