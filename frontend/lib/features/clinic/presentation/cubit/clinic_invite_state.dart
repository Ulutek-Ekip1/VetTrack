import 'package:equatable/equatable.dart';

enum ClinicInviteErrorType {
  invalid,
  expired,
  alreadyUsed,
  network,
  acceptFailed,
  unknown,
}

abstract class ClinicInviteState extends Equatable {
  const ClinicInviteState();

  @override
  List<Object?> get props => [];
}

class ClinicInviteInitial extends ClinicInviteState {
  const ClinicInviteInitial();
}

class ClinicInviteValidating extends ClinicInviteState {
  const ClinicInviteValidating();
}

class ClinicInviteValidated extends ClinicInviteState {
  final String clinicName;
  final String token;
  final String? clinicId;

  const ClinicInviteValidated({
    required this.clinicName,
    required this.token,
    this.clinicId,
  });

  @override
  List<Object?> get props => [clinicName, token, clinicId];
}

class ClinicInviteSubmitting extends ClinicInviteState {
  const ClinicInviteSubmitting();
}

class ClinicInviteSuccess extends ClinicInviteState {
  final String clinicName;
  final String token;

  const ClinicInviteSuccess({
    required this.clinicName,
    required this.token,
  });

  @override
  List<Object?> get props => [clinicName, token];
}

class ClinicInviteError extends ClinicInviteState {
  final String message;
  final ClinicInviteErrorType type;
  final String? token;
  final String? clinicName;

  const ClinicInviteError({
    required this.message,
    required this.type,
    this.token,
    this.clinicName,
  });

  @override
  List<Object?> get props => [message, type, token, clinicName];
}
