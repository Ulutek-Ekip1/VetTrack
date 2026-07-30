import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

class SearchByCodeUseCase {
  final VisitRepository repository;

  SearchByCodeUseCase(this.repository);

  Future<PetEntity> call(String code) async {
    return await repository.searchByCode(code);
  }
}
