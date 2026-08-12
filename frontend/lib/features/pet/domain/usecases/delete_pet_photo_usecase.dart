import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class DeletePetPhotoUseCase {
  final PetRepository repository;

  DeletePetPhotoUseCase(this.repository);

  Future<void> call({required String id}) {
    return repository.deletePetPhoto(id);
  }
}
