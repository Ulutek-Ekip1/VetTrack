import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';

class VisitModel extends VisitEntity {
  const VisitModel({
    required super.id,
    required super.petId,
    required super.vetStaffId,
    super.vetStaffName,
    required super.status,
    required super.startedAt,
    super.endedAt,
    super.chiefComplaint,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'].toString(),
      petId: (json['petId'] ?? json['pet_id'] ?? '').toString(),
      vetStaffId: (json['vetStaffId'] ?? json['vet_staff_id'] ?? '').toString(),
      vetStaffName: (json['vetStaffName'] ?? json['vet_staff_name']).toString(),
      status: (json['status'] ?? 'ongoing').toString(),
      startedAt: json['startedAt'] != null
          ? (DateTime.tryParse(json['startedAt'] as String) ?? DateTime.now())
          : (json['started_at'] != null
              ? (DateTime.tryParse(json['started_at'] as String) ??
                  DateTime.now())
              : DateTime.now()),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : (json['ended_at'] != null
              ? DateTime.tryParse(json['ended_at'] as String)
              : null),
      chiefComplaint:
          (json['chiefComplaint'] ?? json['chief_complaint']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'vetStaffId': vetStaffId,
      if (vetStaffName != null) 'vetStaffName': vetStaffName,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
      if (chiefComplaint != null) 'chiefComplaint': chiefComplaint,
    };
  }
}
