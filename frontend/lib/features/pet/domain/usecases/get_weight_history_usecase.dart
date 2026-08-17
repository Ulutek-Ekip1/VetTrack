import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class GetWeightHistoryUseCase {
  final PetRepository repository;

  GetWeightHistoryUseCase(this.repository);

  Future<List<PetWeightEntity>> call(String petId) async {
    return await repository.getWeightHistory(petId);
  }
}
