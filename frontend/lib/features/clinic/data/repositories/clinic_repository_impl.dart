import '../../domain/entities/invite_validation_entity.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_remote_datasource.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDataSource remoteDataSource;

  ClinicRepositoryImpl(this.remoteDataSource);

  @override
  Future<InviteValidationEntity> validateInviteToken(String token) async {
    return await remoteDataSource.validateInviteToken(token);
  }

  @override
  Future<void> acceptInvite(String token) async {
    return await remoteDataSource.acceptInvite(token);
  }
}
