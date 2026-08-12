import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/treatment/data/models/treatment_entry_model.dart';
import 'package:vettrack_frontend/features/treatment/domain/entities/treatment_entity.dart';

abstract class TreatmentRemoteDataSource {
  Future<List<TreatmentEntity>> getTreatments(String visitId);
  Future<List<TreatmentEntity>> getPetTreatments(String petId);

  Future<TreatmentEntryModel> addTreatment({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  });

  Future<void> deleteTreatment(String treatmentId);
}

class TreatmentRemoteDataSourceImpl implements TreatmentRemoteDataSource {
  final Dio dio;

  TreatmentRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TreatmentEntity>> getTreatments(String visitId) async {
    try {
      final response = await dio.get('/visits/$visitId/treatments');

      final List list = response.data;
      return list
          .map((json) =>
              TreatmentEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Tedavi kayıtları alınamadı.');
    }
  }

  @override
  Future<List<TreatmentEntity>> getPetTreatments(String petId) async {
    try {
      final response = await dio.get('/pets/$petId/treatments');
      return (response.data as List).map((json) => TreatmentEntryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Tedavi kayıtları alınamadı.');
    }
  }

  @override
  Future<TreatmentEntryModel> addTreatment({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  }) async {
    try {
      final response = await dio.post(
        '/visits/$visitId/treatments',
        data: {
          'entryType': type,
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (attachmentUrl != null && attachmentUrl.isNotEmpty)
            'attachmentUrl': attachmentUrl,
        },
      );
      return TreatmentEntryModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Tedavi kaydı eklenemedi.');
    }
  }

  @override
  Future<void> deleteTreatment(String treatmentId) async {
    try {
      await dio.delete('/treatments/$treatmentId');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Tedavi kaydı silinemedi.');
    }
  }
}
