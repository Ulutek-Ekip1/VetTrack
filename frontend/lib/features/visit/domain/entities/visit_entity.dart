import 'package:equatable/equatable.dart';

class VisitEntity extends Equatable {
  final String id;
  final String petId;
  final String vetStaffId;
  final String? vetStaffName;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? chiefComplaint;

  const VisitEntity({
    required this.id,
    required this.petId,
    required this.vetStaffId,
    this.vetStaffName,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.chiefComplaint,
  });

  bool get isOngoing => status == 'ongoing';

  @override
  List<Object?> get props => [
        id,
        petId,
        vetStaffId,
        vetStaffName,
        status,
        startedAt,
        endedAt,
        chiefComplaint,
      ];
}
