import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';

class ActiveVisitContext {
  final VisitEntity visit;
  final PetEntity pet;
  final String ownerName;
  final String? ownerPhone;
  final List<VisitEntity> history;
  const ActiveVisitContext({required this.visit, required this.pet, required this.ownerName, this.ownerPhone, required this.history});
}
