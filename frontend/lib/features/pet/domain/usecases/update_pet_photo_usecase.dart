import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class UpdatePetPhotoUseCase {
  final PetRepository repository;

  UpdatePetPhotoUseCase(this.repository);

  Future<String> call(String petId, String photoUrl) async {
    return await repository.updatePetPhoto(petId, photoUrl);
  }
}
