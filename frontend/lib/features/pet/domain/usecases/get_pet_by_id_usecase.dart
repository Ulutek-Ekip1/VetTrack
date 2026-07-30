import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase(this.repository);

  Future<PetEntity?> call({required String id}) async {
    return await repository.getPetById(id);
  }
}
