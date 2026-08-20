import '../repositories/clinic_repository.dart';

class RegisterAndAcceptInviteUseCase {
  final ClinicRepository repository;

  RegisterAndAcceptInviteUseCase(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String token,
  }) async {
    return await repository.registerAndAcceptInvite(
      email: email,
      password: password,
      name: name,
      phone: phone,
      token: token,
    );
  }
}
