import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';

class StartVisitUseCase {
  final VisitRepository repository;

  StartVisitUseCase(this.repository);

  Future<VisitEntity> call(String petId) async {
    return await repository.startVisit(petId);
  }
}
