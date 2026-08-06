import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:vettrack_frontend/features/recommendation/domain/repositories/recommendation_repository.dart';

class AddRecommendationUseCase {
  final RecommendationRepository repository;

  AddRecommendationUseCase(this.repository);

  Future<RecommendationEntity> call({
    required String visitId,
    required String type,
    required String description,
  }) async {
    return await repository.addRecommendation(
      visitId: visitId,
      type: type,
      description: description,
    );
  }
}
