import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

abstract class VisitRepository {
  Future<PetEntity> searchByCode(String code);
  Future<VisitEntity> startVisit(String petId);
  Future<void> closeVisit(String visitId);
  Future<List<VisitEntity>> getOwnerVisitHistory();
  Future<List<VisitEntity>> getVetVisitHistory();
  Future<List<VisitEntity>> getPetVisitHistory(String petId);
}
