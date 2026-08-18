import '../entities/invite_validation_entity.dart';
import '../repositories/clinic_repository.dart';

class ValidateInviteUseCase {
  final ClinicRepository repository;

  ValidateInviteUseCase(this.repository);

  Future<InviteValidationEntity> call(String token) async {
    return await repository.validateInviteToken(token);
  }
}
