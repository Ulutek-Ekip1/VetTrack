import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUsecase {
  final AuthRepository authRepository;

  DeleteAccountUsecase(this.authRepository);

  Future<void> call(String password) async {
    await authRepository.deleteAccount(password);
  }
}
