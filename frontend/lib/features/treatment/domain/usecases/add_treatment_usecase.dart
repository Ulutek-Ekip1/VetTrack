import '../entities/treatment_entity.dart';
import '../repositories/treatment_repository.dart';

class AddTreatmentUseCase {
  final TreatmentRepository repository;

  AddTreatmentUseCase(this.repository);

  Future<TreatmentEntity> call({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  }) async {
    return await repository.addTreatment(
      visitId: visitId,
      type: type,
      title: title,
      description: description,
      attachmentUrl: attachmentUrl,
    );
  }
}
