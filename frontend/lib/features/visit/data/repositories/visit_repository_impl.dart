import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/active_visit_context.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;

  VisitRepositoryImpl(this.remoteDataSource);

  @override
  Future<PatientSearchResult> searchByCode(String code) async {
    return await remoteDataSource.searchByCode(code);
  }

  @override
  Future<VisitEntity> startVisit(String petId) async {
    return await remoteDataSource.startVisit(petId);
  }

  @override
  Future<void> closeVisit(String visitId) async {
    await remoteDataSource.closeVisit(visitId);
  }

  @override
  Future<List<VisitEntity>> getOwnerVisitHistory() async {
    return await remoteDataSource.getOwnerVisitHistory();
  }

  @override
  Future<List<VisitEntity>> getVetVisitHistory() async {
    return await remoteDataSource.getVetVisitHistory();
  }

  @override
  Future<List<VisitEntity>> getPetVisitHistory(String petId) async {
    return await remoteDataSource.getPetVisitHistory(petId);
  }

  @override
  Future<ActiveVisitContext> getActiveVisitContext(String visitId) => remoteDataSource.getActiveVisitContext(visitId);
}
