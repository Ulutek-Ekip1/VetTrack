import '../repositories/clinic_repository.dart';

class AcceptInviteUseCase {
  final ClinicRepository repository;

  AcceptInviteUseCase(this.repository);

  Future<void> call(String token) async {
    return await repository.acceptInvite(token);
  }
}
