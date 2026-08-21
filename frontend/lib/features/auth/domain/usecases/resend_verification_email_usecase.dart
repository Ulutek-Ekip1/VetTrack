import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';

class ResendVerificationEmailUsecase {
  final AuthRepository authRepository;

  ResendVerificationEmailUsecase(this.authRepository);

  Future<void> call(String email) async {
    await authRepository.resendVerificationEmail(email);
  }
}
