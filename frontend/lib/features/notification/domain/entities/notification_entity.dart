import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String ownerId;
  final String? treatmentEntryId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? sentAt;

  const NotificationEntity({
    required this.id,
    required this.ownerId,
    this.treatmentEntryId,
    required this.title,
    required this.body,
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
        isRead,
        sentAt,
      ];
}
