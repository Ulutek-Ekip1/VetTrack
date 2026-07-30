import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);
  Future<PetEntity> call({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
  }) async {
    return await repository.addPet(
      name: name,
      gender: gender,
      age: age,
      breed: breed,
    );
  }
}
