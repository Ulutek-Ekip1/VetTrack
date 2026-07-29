import 'package:vettrack_frontend/features/pet/data/datasources/pet_remote_datasource.dart';

class PetRepositoryImpl {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl(this.remoteDataSource);
}
