import '../entities/invite_validation_entity.dart';

abstract class ClinicRepository {
  Future<InviteValidationEntity> validateInviteToken(String token);
  Future<void> acceptInvite(String token);
  Future<void> registerAndAcceptInvite({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String token,
  });
}
