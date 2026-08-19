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
    final startedAtVal = json['startedAt'] ?? json['started_at'];
    if (startedAtVal == null) {
      throw const FormatException('Ziyaret başlangıç tarihi bulunamadı.');
    }
    if (startedAtVal is! String) {
      throw const FormatException('Ziyaret başlangıç tarihi formatı desteklenmiyor.');
    }
    final startedAt = DateTime.tryParse(startedAtVal);
    if (startedAt == null) {
      throw const FormatException('Ziyaret başlangıç tarihi geçersiz bir zaman biçiminde.');
    }

    final endedAtVal = json['endedAt'] ?? json['ended_at'];
    DateTime? endedAt;
    if (endedAtVal != null) {
      if (endedAtVal is! String) {
        throw const FormatException('Ziyaret bitiş tarihi formatı desteklenmiyor.');
      }
      endedAt = DateTime.tryParse(endedAtVal);
      if (endedAt == null) {
        throw const FormatException('Ziyaret bitiş tarihi geçersiz bir zaman biçiminde.');
      }
    }

    return VisitModel(
      id: json['id'].toString(),
      petId: (json['petId'] ?? json['pet_id'] ?? '').toString(),
      vetStaffId: (json['vetStaffId'] ?? json['vet_staff_id'] ?? '').toString(),
      vetStaffName:
          (json['vetStaffName'] ?? json['vet_staff_name'])?.toString(),
      status: (json['status'] ?? 'ongoing').toString(),
      startedAt: startedAt,
      endedAt: endedAt,
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
