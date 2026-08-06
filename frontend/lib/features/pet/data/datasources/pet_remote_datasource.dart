import 'package:dio/dio.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';

abstract class PetRemoteDataSource {
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
  Future<void> deletePet(String id);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final Dio dio;

  PetRemoteDataSourceImpl(this.dio);

  @override
  Future<PetEntity> addPet({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
  }) async {
    try {
      String speciesVal = 'Bilinmiyor';
      String? breedVal = breed;
      if (breed != null) {
        if (breed.contains(' / ')) {
          final parts = breed.split(' / ');
          speciesVal = parts[0];
          breedVal = parts[1];
        } else {
          speciesVal = breed;
          breedVal = null;
        }
      }

      final response = await dio.post(
        '/pets',
        data: {
          'name': name,
          'gender': gender.name,
          'species': speciesVal,
          if (breedVal != null) 'breed': breedVal,
          if (age != null) 'estimatedBirthYear': DateTime.now().year - age,
        },
      );
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<PetEntity>> getPets() async {
    try {
      final response = await dio.get('/pets');
      final List<dynamic> petsJson = response.data;
      return petsJson.map((json) => PetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PetEntity> getPetById(String id) async {
    try {
      final response = await dio.get('/pets/$id');
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<PetEntity> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
  }) async {
    try {
      String? speciesVal;
      String? breedVal;
      if (breed != null) {
        if (breed.contains(' / ')) {
          final parts = breed.split(' / ');
          speciesVal = parts[0];
          breedVal = parts[1];
        } else {
          speciesVal = breed;
          breedVal = null;
        }
      }

      final response = await dio.put(
        '/pets/$id',
        data: {
          if (name != null) 'name': name,
          if (gender != null) 'gender': gender.name,
          if (speciesVal != null) 'species': speciesVal,
          if (breedVal != null) 'breed': breedVal,
          if (age != null) 'estimatedBirthYear': DateTime.now().year - age,
        },
      );
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> updatePetPhoto(String id, String photoFilePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(photoFilePath),
      });

      final response = await dio.post(
        '/pets/$id/photo',
        data: formData,
      );
      return response.data['photoUrl'] as String;
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deletePet(String id) async {
    try {
      await dio.delete('/pets/$id');
    } on DioException catch (e) {
      throw ServerException(e.message);
    }
  }
}
