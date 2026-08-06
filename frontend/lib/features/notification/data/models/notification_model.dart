import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.ownerId,
    super.treatmentEntryId,
    required super.title,
    required super.body,
    required super.isRead,
    super.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      treatmentEntryId: json['treatmentEntryId'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      if (treatmentEntryId != null) 'treatmentEntryId': treatmentEntryId,
      'title': title,
      'body': body,
      'isRead': isRead,
      if (sentAt != null) 'sentAt': sentAt!.toIso8601String(),
    };
  }
}
