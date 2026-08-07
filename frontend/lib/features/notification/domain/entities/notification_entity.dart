import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String ownerId;
  final String? treatmentEntryId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? sentAt;

  const NotificationEntity({
    required this.id,
    required this.ownerId,
    this.treatmentEntryId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.sentAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        treatmentEntryId,
        title,
        body,
        type,
        isRead,
        sentAt,
      ];
}

class NotificationListEntity extends Equatable {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationListEntity({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}
