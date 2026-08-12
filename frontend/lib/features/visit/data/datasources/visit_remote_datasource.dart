import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';
import 'package:vettrack_frontend/features/visit/data/models/patient_search_result_model.dart';

abstract class VisitRemoteDataSource {
  Future<PatientSearchResultModel> searchByCode(String code);
  Future<VisitModel> startVisit(String petId);
  Future<void> closeVisit(String visitId);
  Future<List<VisitModel>> getOwnerVisitHistory();
  Future<List<VisitModel>> getVetVisitHistory();
  Future<List<VisitModel>> getPetVisitHistory(String petId);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final Dio dio;

  VisitRemoteDataSourceImpl(this.dio);

  @override
  Future<PatientSearchResultModel> searchByCode(String code) async {
    try {
      final response = await dio.get('/visits/code/${Uri.encodeComponent(code)}');
      return PatientSearchResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Kod bulunamadı. Lütfen erişim kodunu kontrol edin.');
      }
      final data = e.response?.data;
      final message = data is Map<String, dynamic> ? data['message'] as String? : null;
      throw ServerException(message ?? e.message);
    }
  }

  @override
  Future<VisitModel> startVisit(String petId) async {
    try {
      final response = await dio.post('/visits', data: {'petId': petId});
      return VisitModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> closeVisit(String visitId) async {
    try {
      await dio.put('/visits/$visitId/close');
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<VisitModel>> getOwnerVisitHistory() async {
    try {
      final response = await dio.get('/visits/owner');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<VisitModel>> getVetVisitHistory() async {
    try {
      final response = await dio.get('/visits/vet');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<VisitModel>> getPetVisitHistory(String petId) async {
    try {
      final response = await dio.get('/pets/$petId/visits');
      final List<dynamic> list = response.data;
      return list.map((json) => VisitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }
}
