import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

abstract class PetRepository {
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
  });
  Future<List<PetEntity>> getPets();
  Future<PetEntity> getPetById(String id);
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
  });
  Future<String> updatePetPhoto(String id, String photoFilePath);
  Future<void> deletePet(String id);
  Future<void> deletePetPhoto(String id);
  Future<List<PetWeightEntity>>getWeightHistory(String petId);
}
