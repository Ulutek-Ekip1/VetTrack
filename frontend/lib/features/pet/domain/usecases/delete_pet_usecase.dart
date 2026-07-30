import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deletePet(id);
  }
}
