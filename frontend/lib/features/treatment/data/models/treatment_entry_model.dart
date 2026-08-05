import '../../domain/entities/treatment_entity.dart';

class TreatmentEntryModel extends TreatmentEntity {
  const TreatmentEntryModel({
    required super.id,
    required super.visitId,
    required super.type,
    required super.title,
    super.description,
    super.attachmentUrl,
    super.enteredBy,
    required super.status,
    super.startDate,
    super.endDate,
    super.editable,
    super.createdAt,
  });

  factory TreatmentEntryModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String?;
    TreatmentStatus parsedStatus = TreatmentStatus.planned; // Default

    if (statusStr == 'IN_PROGRESS' || statusStr == 'in_progress') {
      parsedStatus = TreatmentStatus.inProgress;
    } else if (statusStr == 'COMPLETED' || statusStr == 'completed') {
      parsedStatus = TreatmentStatus.completed;
    } else if (statusStr == 'CANCELLED' || statusStr == 'cancelled') {
      parsedStatus = TreatmentStatus.cancelled;
    }

    return TreatmentEntryModel(
      id: (json['id'] ?? json['treatment_id'] ?? '').toString(),
      visitId: (json['visitId'] ?? json['visit_id'] ?? '').toString(),
      type: (json['type'] ?? 'note').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description'] as String?,
      attachmentUrl: (json['attachmentUrl'] ?? json['attachment_url']) as String?,
      enteredBy: (json['enteredBy'] ?? json['entered_by'] ?? '').toString(),
      status: parsedStatus,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : (json['start_date'] != null
              ? DateTime.tryParse(json['start_date'] as String)
              : null),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : (json['end_date'] != null
              ? DateTime.tryParse(json['end_date'] as String)
              : null),
      editable: json['editable'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr = 'PLANNED';
    if (status == TreatmentStatus.inProgress) {
      statusStr = 'IN_PROGRESS';
    } else if (status == TreatmentStatus.completed) {
      statusStr = 'COMPLETED';
    } else if (status == TreatmentStatus.cancelled) {
      statusStr = 'CANCELLED';
    }

    return {
      'id': id,
      'visitId': visitId,
      'type': type,
      'title': title,
      if (description != null) 'description': description,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (enteredBy != null) 'enteredBy': enteredBy,
      'status': statusStr,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'editable': editable,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
