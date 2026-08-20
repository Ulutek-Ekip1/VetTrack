import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import 'notification_state.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/register_device_token_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final FirebaseMessagingService firebaseMessagingService;
  late final StreamSubscription<void> _notificationSubscription;

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.registerDeviceTokenUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.getUnreadCountUseCase,
    required this.firebaseMessagingService,
  }) : super(NotificationInitial()) {
    _notificationSubscription =
        firebaseMessagingService.notificationEvents.listen((_) {
      loadNotifications();
    });
  }

  //Kullanicinin gecmis bilgilerini yukleme
  Future<void> loadNotifications() async {
    emit(NotificationLoading());

    try {
      final notificationsList = await getNotificationsUseCase();
      emit(NotificationLoaded(notificationsList));
    } catch (e) {
      emit(NotificationError("Bildirimler yüklenemedi: ${e.toString()}"));
    }
  }

  Future<void> refresh() => loadNotifications();

  //Tokeni sunucuya kaydetme
  Future<void> registerDeviceToken(String token,
      {String platform = 'android'}) async {
    try {
      await registerDeviceTokenUseCase(fcmToken: token, platform: platform);
      emit(DeviceTokenRegistered());
    } catch (e) {
      emit(NotificationError("Cihaz token'ı kaydedilemedi: ${e.toString()}"));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await markAsReadUseCase(id);
      // Reload notifications to update state locally
      await loadNotifications();
    } catch (e) {
      // Opt: show error or just ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await markAllAsReadUseCase();
      await loadNotifications();
    } catch (e) {
      // Opt: show error or just ignore
    }
  }

  @override
  Future<void> close() async {
    await _notificationSubscription.cancel();
    return super.close();
  }
}
