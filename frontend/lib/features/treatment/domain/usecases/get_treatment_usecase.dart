import '../entities/treatment_entity.dart';
import '../repositories/treatment_repository.dart';

class GetTreatmentUseCase {
  final TreatmentRepository repository;

  GetTreatmentUseCase(this.repository);

  Future<List<TreatmentEntity>> call(String visitId) async {
    return await repository.getTreatments(visitId);
  }
}
