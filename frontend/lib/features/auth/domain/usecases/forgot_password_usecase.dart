import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository authRepository;

  ForgotPasswordUseCase(this.authRepository);

  Future<void> call(String email) async {
    await authRepository.forgotPassword(email);
  }
}
