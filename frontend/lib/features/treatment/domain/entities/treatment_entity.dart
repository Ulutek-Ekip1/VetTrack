import 'package:equatable/equatable.dart';

enum TreatmentStatus { planned, inProgress, completed, cancelled }

class TreatmentEntity extends Equatable {
  final String id;
  final String visitId;
  final String type;
  final String title;
  final String? description;
  final String? attachmentUrl;
  final String? enteredBy;
  final TreatmentStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool editable;
  final DateTime? createdAt;

  const TreatmentEntity({
    required this.id,
    required this.visitId,
    required this.type,
    required this.title,
    this.description,
    this.attachmentUrl,
    this.enteredBy,
    this.status = TreatmentStatus.planned,
    this.startDate,
    this.endDate,
    this.editable = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        visitId,
        type,
        title,
        description,
        attachmentUrl,
        enteredBy,
        status,
        startDate,
        endDate,
        editable,
        createdAt
      ];
}
