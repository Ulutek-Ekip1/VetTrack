import 'package:vettrack_frontend/features/treatment/domain/entities/treatment_entity.dart';

abstract class TreatmentRepository {
  Future<List<TreatmentEntity>> getTreatments(String visitId);
  Future<TreatmentEntity> addTreatment({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  });
  Future<void> deleteTreatment(String treatmentId);
}
