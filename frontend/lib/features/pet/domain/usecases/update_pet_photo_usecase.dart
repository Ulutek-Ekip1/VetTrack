import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class UpdatePetPhotoUseCase {
  final PetRepository repository;

  UpdatePetPhotoUseCase(this.repository);

  Future<String> call({required String photoPath, required String id}) async {
    return await repository.updatePetPhoto(id, photoPath);
  }
}
