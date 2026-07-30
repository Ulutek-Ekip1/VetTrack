import 'package:vettrack_frontend/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl(this.remoteDataSource);

  @override
  Future<PetEntity> addPet({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
  }) async {
    return await remoteDataSource.addPet(
      name: name,
      gender: gender,
      age: age,
      breed: breed,
    );
  }

  @override
  Future<List<PetEntity>> getPets() async {
    return await remoteDataSource.getPets();
  }

  @override
  Future<PetEntity> getPetById(String id) async {
    return await remoteDataSource.getPetById(id);
  }

  @override
  Future<PetEntity> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
  }) async {
    return await remoteDataSource.updatePet(
      id: id,
      name: name,
      gender: gender,
      age: age,
      breed: breed,
    );
  }

  @override
  Future<String> updatePetPhoto(String id, String photoFilePath) async {
    return await remoteDataSource.updatePetPhoto(id, photoFilePath);
  }

  /* @override
  Future<List<VisitDetailEntity>> getPetVisits(String id) async {
    return await remoteDataSource.getPetVisits(id);
  }

  @override
  Future<List<RecommendationDetailEntity>> getPetRecommendations(
      String id) async {
    return await remoteDataSource.getPetRecommendations(id);
  } */
}
