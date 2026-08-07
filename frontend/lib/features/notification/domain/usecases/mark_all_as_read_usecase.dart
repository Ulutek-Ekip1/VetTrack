import '../repositories/notification_repository.dart';

class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<void> call() async {
    return await repository.markAllAsRead();
  }
}
