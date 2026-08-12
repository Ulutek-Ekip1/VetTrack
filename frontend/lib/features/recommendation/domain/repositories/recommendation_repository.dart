import '../entities/recommendation_entity.dart';

abstract class RecommendationRepository {
  Future<List<RecommendationEntity>> getRecommendations(String petId);
  Future<List<RecommendationEntity>> getVisitRecommendations(String visitId);
  Future<RecommendationEntity> addRecommendation({
    required String visitId,
    required String type,
    required String description,
  });
}
