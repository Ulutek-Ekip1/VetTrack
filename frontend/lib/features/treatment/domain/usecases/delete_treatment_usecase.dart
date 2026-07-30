import '../repositories/treatment_repository.dart';

class DeleteTreatmentUseCase {
  final TreatmentRepository repository;

  DeleteTreatmentUseCase(this.repository);

  Future<void> call(String treatmentId) async {
    await repository.deleteTreatment(treatmentId);
  }
}
