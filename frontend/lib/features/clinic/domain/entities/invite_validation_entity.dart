import 'package:equatable/equatable.dart';

class InviteValidationEntity extends Equatable {
  final bool isValid;
  final String clinicName;
  final String? clinicId;

  const InviteValidationEntity({
    required this.isValid,
    required this.clinicName,
    this.clinicId,
  });

  @override
  List<Object?> get props => [isValid, clinicName, clinicId];
}
