import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';

abstract class VisitRepository {
  Future<PatientSearchResult> searchByCode(String code);
  Future<VisitEntity> startVisit(String petId);
  Future<void> closeVisit(String visitId);
  Future<List<VisitEntity>> getOwnerVisitHistory();
  Future<List<VisitEntity>> getVetVisitHistory();
  Future<List<VisitEntity>> getPetVisitHistory(String petId);
}
