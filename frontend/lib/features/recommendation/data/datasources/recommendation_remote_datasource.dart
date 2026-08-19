import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/recommendation/data/models/recommendation_model.dart';
import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationEntity>> getRecommendations(String petId);
  Future<List<RecommendationEntity>> getVisitRecommendations(String visitId);
  Future<RecommendationEntity> addRecommendation({
    required String visitId,
    required String type,
    required String description,
  });
}

//API implementasyonu
class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  final Dio dio;

  RecommendationRemoteDataSourceImpl(this.dio);

  //Belirli petId için öneri getirir.
  @override
  Future<List<RecommendationEntity>> getRecommendations(String petId) async {
    try {
      final response = await dio.get('/pets/$petId/recommendations');
      final List list = response.data;
      return list
          .map((json) =>
              RecommendationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Öneriler alınamadı.');
    }
  }

  @override
  Future<List<RecommendationEntity>> getVisitRecommendations(String visitId) async {
    try {
      final response = await dio.get('/visits/$visitId/recommendations');
      return (response.data as List).map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Öneriler alınamadı.');
    }
  }

//Yeni öneri ekleme
  @override
  Future<RecommendationEntity> addRecommendation({
    required String visitId,
    required String type,
    required String description,
  }) async {
    try {
      final response = await dio.post(
        '/visits/$visitId/recommendations',
        data: {
          'type': type,
          'description': description,
        },
      );
      return RecommendationModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Öneri eklenemedi.');
    }
  }
}
