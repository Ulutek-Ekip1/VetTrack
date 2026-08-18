import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/active_visit_context.dart';

abstract class VisitRepository {
  Future<PatientSearchResult> searchByCode(String code, String clinicId);
  Future<VisitEntity> startVisit(String petId);
  Future<void> closeVisit(String visitId);
  Future<List<VisitEntity>> getOwnerVisitHistory();
  Future<List<VisitEntity>> getVetVisitHistory();
  Future<List<VisitEntity>> getPetVisitHistory(String petId);
  Future<ActiveVisitContext> getActiveVisitContext(String visitId);
}
