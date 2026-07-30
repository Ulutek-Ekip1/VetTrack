import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_state.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/register_device_token_usecase.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.registerDeviceTokenUseCase,
  }) : super(NotificationInitial());

  //Kullanicinin gecmis bilgilerini yukleme
  Future<void> loadNotifications() async {
    emit(NotificationLoading());

    try {
      final notifications = await getNotificationsUseCase();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError("Bildirimler yüklenemedi: ${e.toString()}"));
    }
  }

  //Tokeni sunucuya kaydetme
  Future<void> registerDeviceToken(String token, {String platform = 'android'}) async {
    try {
      await registerDeviceTokenUseCase(fcmToken: token, platform: platform);
      emit(DeviceTokenRegistered());
    } catch (e) {
      emit(NotificationError("Cihaz token'ı kaydedilemedi: ${e.toString()}"));
    }
  }
}
