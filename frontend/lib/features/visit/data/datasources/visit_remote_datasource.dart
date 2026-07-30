import 'package:dio/dio.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';
import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';

abstract class VisitRemoteDataSource {
  Future<PetModel> searchByCode(String code);
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
  Future<PetModel> searchByCode(String code) async {
    try {
      final response = await dio.get('/visits/code/$code');
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message);
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
