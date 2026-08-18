import '../entities/invite_validation_entity.dart';

abstract class ClinicRepository {
  Future<InviteValidationEntity> validateInviteToken(String token);
  Future<void> acceptInvite(String token);
}
