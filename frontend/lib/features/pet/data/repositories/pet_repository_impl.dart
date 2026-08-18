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
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
  }) async {
    return await remoteDataSource.addPet(
      name: name,
      gender: gender,
      age: age,
      breed: breed,
      birthDate: birthDate,
      weight: weight,
      microchipNo: microchipNo,
      isSpayedOrNeutered: isSpayedOrNeutered,
      bloodType: bloodType,
      color: color,
      allergies: allergies,
      chronicIllnesses: chronicIllnesses,
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
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
  }) async {
    return await remoteDataSource.updatePet(
      id: id,
      name: name,
      gender: gender,
      age: age,
      breed: breed,
      birthDate: birthDate,
      weight: weight,
      microchipNo: microchipNo,
      isSpayedOrNeutered: isSpayedOrNeutered,
      bloodType: bloodType,
      color: color,
      allergies: allergies,
      chronicIllnesses: chronicIllnesses,
    );
  }

  @override
  Future<String> updatePetPhoto(String id, String photoFilePath) async {
    return await remoteDataSource.updatePetPhoto(id, photoFilePath);
  }

  @override
  Future<void> deletePet(String id) async {
    await remoteDataSource.deletePet(id);
  }

  @override
  Future<void> deletePetPhoto(String id) async {
    await remoteDataSource.deletePetPhoto(id);
  }

  @override
  Future<List<PetWeightEntity>> getWeightHistory(String petId) async {
    return await remoteDataSource.getWeightHistory(petId);
  }
}
