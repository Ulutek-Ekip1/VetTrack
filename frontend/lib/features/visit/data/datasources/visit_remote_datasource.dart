import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';
import 'package:vettrack_frontend/features/visit/data/models/patient_search_result_model.dart';
import 'package:vettrack_frontend/features/visit/data/models/active_visit_context_model.dart';

abstract class VisitRemoteDataSource {
  Future<PatientSearchResultModel> searchByCode(String code, String clinicId);
  Future<VisitModel> startVisit(String petId);
  Future<void> closeVisit(String visitId);
  Future<List<VisitModel>> getOwnerVisitHistory();
  Future<List<VisitModel>> getVetVisitHistory();
  Future<List<VisitModel>> getPetVisitHistory(String petId);
  Future<ActiveVisitContextModel> getActiveVisitContext(String visitId);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final Dio dio;

  VisitRemoteDataSourceImpl(this.dio);

  @override
  Future<PatientSearchResultModel> searchByCode(
      String code, String clinicId) async {
    try {
      final response = await dio.get(
        '/visits/code/${Uri.encodeComponent(code)}',
        queryParameters: clinicId.isNotEmpty ? {'clinicId': clinicId} : null,
      );
      return PatientSearchResultModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerException(
            'Kod bulunamadı. Lütfen erişim kodunu kontrol edin.', 404);
      }
      throw ServerException.fromDio(e, defaultMessage: 'Hasta arama işlemi gerçekleştirilemedi.');
    }
  }

  @override
  Future<VisitModel> startVisit(String petId) async {
    try {
      final response = await dio.post('/visits', data: {'petId': petId});
      return VisitModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Muayene başlatılamadı.');
    }
  }

  @override
  Future<void> closeVisit(String visitId) async {
    try {
      await dio.put('/visits/$visitId/close');
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Muayene kapatılamadı.');
    }
  }

  @override
  Future<List<VisitModel>> getOwnerVisitHistory() async {
    try {
      final response = await dio.get('/visits/owner');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Ziyaret geçmişi alınamadı.');
    }
  }

  @override
  Future<List<VisitModel>> getVetVisitHistory() async {
    try {
      final response = await dio.get('/visits/vet');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Muayene geçmişi alınamadı.');
    }
  }

  @override
  Future<List<VisitModel>> getPetVisitHistory(String petId) async {
    try {
      final response = await dio.get('/visits/pets/$petId/visits');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Pet muayene geçmişi alınamadı.');
    }
  }

  @override
  Future<ActiveVisitContextModel> getActiveVisitContext(String visitId) async {
    try {
      final response = await dio.get('/visits/$visitId/context');
      return ActiveVisitContextModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e, defaultMessage: 'Aktif muayene bilgisi alınamadı.');
    }
  }
}
