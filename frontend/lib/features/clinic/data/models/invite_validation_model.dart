import '../../domain/entities/invite_validation_entity.dart';

class InviteValidationModel extends InviteValidationEntity {
  const InviteValidationModel({
    required super.isValid,
    required super.clinicName,
    super.clinicId,
  });

  factory InviteValidationModel.fromJson(Map<String, dynamic> json) {
    final validVal = json['valid'] == true || json['isValid'] == true;
    final nameVal = (json['clinicName'] ?? json['clinic_name'] ?? 'Veteriner Kliniği').toString();
    final idVal = (json['clinicId'] ?? json['clinic_id'])?.toString();

    return InviteValidationModel(
      isValid: validVal,
      clinicName: nameVal,
      clinicId: idVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': isValid,
      'clinicName': clinicName,
      if (clinicId != null) 'clinicId': clinicId,
    };
  }
}
