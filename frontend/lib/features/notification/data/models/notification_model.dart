import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.ownerId,
    super.treatmentEntryId,
    required super.title,
    required super.body,
    required super.type,
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
      type: json['type'] as String? ?? 'SYSTEM',
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
      'type': type,
      'isRead': isRead,
      if (sentAt != null) 'sentAt': sentAt!.toIso8601String(),
    };
  }
}

class NotificationListModel extends NotificationListEntity {
  const NotificationListModel({
    required super.notifications,
    required super.unreadCount,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    final list = json['notifications'] as List? ?? [];
    return NotificationListModel(
      notifications: list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
