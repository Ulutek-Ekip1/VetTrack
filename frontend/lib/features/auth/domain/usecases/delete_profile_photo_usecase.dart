import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';

class DeleteProfilePhotoUseCase {
  final AuthRepository authRepository;
  DeleteProfilePhotoUseCase(this.authRepository);

  Future<void> call() async {
    await authRepository.deleteProfilePhoto();
  }
}
