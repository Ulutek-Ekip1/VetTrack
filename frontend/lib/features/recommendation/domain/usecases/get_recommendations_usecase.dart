import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:vettrack_frontend/features/recommendation/domain/repositories/recommendation_repository.dart';

class GetRecommendationsUseCase {
  final RecommendationRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<List<RecommendationEntity>> call(String petId) async {
    return await repository.getRecommendations(petId);
  }
}
