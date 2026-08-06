import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:vettrack_frontend/features/recommendation/domain/repositories/recommendation_repository.dart';
import 'package:vettrack_frontend/features/recommendation/data/datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  RecommendationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RecommendationEntity>> getRecommendations(String petId) async {
    return await remoteDataSource.getRecommendations(petId);
  }

  @override
  Future<RecommendationEntity> addRecommendation({
    required String visitId,
    required String type,
    required String description,
  }) async {
    return await remoteDataSource.addRecommendation(
      visitId: visitId,
      type: type,
      description: description,
    );
  }
}
