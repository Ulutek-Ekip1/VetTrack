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
    super.editable,
    super.createdAt,
  });

  factory TreatmentEntryModel.fromJson(Map<String, dynamic> json) {
    return TreatmentEntryModel(
      id: json['id'] as String? ?? '',
      visitId: json['visitId'] as String? ?? '',
      type: json['type'] as String? ?? 'note',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      enteredBy: json['enteredBy'] as String?,
      editable: json['editable'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitId': visitId,
      'type': type,
      'title': title,
      if (description != null) 'description': description,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (enteredBy != null) 'enteredBy': enteredBy,
      'editable': editable,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
