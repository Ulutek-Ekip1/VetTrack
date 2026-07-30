import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

abstract class PetRepository {
  Future<PetEntity> addPet({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
  });
  Future<List<PetEntity>> getPets();
  Future<PetEntity> getPetById(String id);
  Future<PetEntity> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
  });
  Future<String> updatePetPhoto(String id, String photoFilePath);
  /* Future<List<VisitDetailEntity>> getPetVisits(String id); */
  /*  Future<List<RecommendationDetailEntity>> getPetRecommendations(String id); */
}
