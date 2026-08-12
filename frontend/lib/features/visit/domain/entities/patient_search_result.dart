import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';

class PatientSearchResult {
  final PetEntity pet;
  final List<VisitEntity> visits;

  const PatientSearchResult({required this.pet, required this.visits});

  VisitEntity? get activeVisit {
    for (final visit in visits) {
      if (visit.isOngoing) return visit;
    }
    return null;
  }
}
