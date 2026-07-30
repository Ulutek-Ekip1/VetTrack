// GetOwnerPets UseCase
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class GetOwnerPetsUseCase {
  PetRepository repository;

  GetOwnerPetsUseCase(this.repository);
  Future<List<PetEntity>> call() async {
    return await repository.getPets();
  }
}
