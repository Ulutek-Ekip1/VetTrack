import '../../domain/entities/treatment_entity.dart';
import '../../domain/repositories/treatment_repository.dart';
import '../datasources/treatment_remote_datasource.dart';

class TreatmentRepositoryImpl implements TreatmentRepository {
  final TreatmentRemoteDataSource remoteDataSource;

  TreatmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TreatmentEntity>> getTreatments(String visitId) async {
    return await remoteDataSource.getTreatments(visitId);
  }

  @override
  Future<List<TreatmentEntity>> getPetTreatments(String petId) => remoteDataSource.getPetTreatments(petId);

  @override
  Future<TreatmentEntity> addTreatment({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  }) async {
    return await remoteDataSource.addTreatment(
      visitId: visitId,
      type: type,
      title: title,
      description: description,
      attachmentUrl: attachmentUrl,
    );
  }

  @override
  Future<void> deleteTreatment(String treatmentId) async {
    await remoteDataSource.deleteTreatment(treatmentId);
  }
}
