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
      id: json['id'] as String,
      petId: (json['petId'] ?? json['pet_id'] ?? '') as String,
      vetStaffId: (json['vetStaffId'] ?? json['vet_staff_id'] ?? '').toString(),
      vetStaffName: (json['vetStaffName'] ?? json['vet_staff_name']) as String?,
      status: (json['status'] ?? 'ongoing') as String,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : (json['started_at'] != null
              ? DateTime.parse(json['started_at'] as String)
              : DateTime.now()),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : (json['ended_at'] != null
              ? DateTime.parse(json['ended_at'] as String)
              : null),
      chiefComplaint: (json['chiefComplaint'] ?? json['chief_complaint']) as String?,
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
