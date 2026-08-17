import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfilePhotoUseCase {
  final AuthRepository authRepository;
  UpdateProfilePhotoUseCase(this.authRepository);

  Future<String> call(String filePath) async {
    return await authRepository.updateProfilePhoto(filePath);
  }
}
