import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<PetEntity> call(
      {required String id,
      String? name,
      Gender? gender,
      int? age,
      String? breed}) async {
    return await repository.updatePet(
      id: id,
      name: name,
      gender: gender,
      age: age,
      breed: breed,
    );
  }
}
