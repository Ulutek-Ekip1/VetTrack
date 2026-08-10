import '../repositories/notification_repository.dart';

class UnregisterDeviceTokenUseCase {
  final NotificationRepository repository;

  UnregisterDeviceTokenUseCase(this.repository);

  Future<void> call({required String fcmToken}) async {
    await repository.unregisterDeviceToken(fcmToken: fcmToken);
  }
}
