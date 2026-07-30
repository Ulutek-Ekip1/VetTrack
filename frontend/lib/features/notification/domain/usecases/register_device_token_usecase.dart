import '../repositories/notification_repository.dart';

class RegisterDeviceTokenUseCase {
  final NotificationRepository repository;

  RegisterDeviceTokenUseCase(this.repository);

  Future<void> call({required String fcmToken, String platform = 'android'}) async {
    await repository.registerDeviceToken(fcmToken: fcmToken, platform: platform);
  }
}
