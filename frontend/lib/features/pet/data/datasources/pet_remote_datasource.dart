import 'package:dio/dio.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';
import 'package:vettrack_frontend/core/error/error_handler.dart';
import 'package:http_parser/http_parser.dart';

abstract class PetRemoteDataSource {
  Future<PetEntity> addPet({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
  });
  Future<List<PetEntity>> getPets();
  Future<PetEntity> getPetById(String id);
  Future<List<PetWeightEntity>> getWeightHistory(String petId);
  Future<PetEntity> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
  });
  Future<String> updatePetPhoto(String id, String photoFilePath);
  Future<void> deletePetPhoto(String id);
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
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
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
          if (birthDate != null)
            'birthDate': birthDate.toIso8601String().split('T')[0],
          if (weight != null) 'weight': weight,
          if (microchipNo != null) 'microchipNo': microchipNo,
          if (isSpayedOrNeutered != null)
            'isSpayedOrNeutered': isSpayedOrNeutered,
          if (bloodType != null) 'bloodType': bloodType,
          if (color != null) 'color': color,
          if (allergies != null) 'allergies': allergies,
          if (chronicIllnesses != null) 'chronicIllnesses': chronicIllnesses,
        },
      );
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan eklenemedi.');
    }
  }

  @override
  Future<List<PetEntity>> getPets() async {
    try {
      final response = await dio.get('/pets');
      final List<dynamic> petsJson = response.data;
      return petsJson.map((json) => PetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvanlar alınamadı.');
    }
  }

  @override
  Future<PetEntity> getPetById(String id) async {
    try {
      final response = await dio.get('/pets/$id');
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan detayı alınamadı.');
    }
  }

  @override
  Future<PetEntity> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
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
          if (birthDate != null)
            'birthDate': birthDate.toIso8601String().split('T')[0],
          if (weight != null) 'weight': weight,
          if (microchipNo != null) 'microchipNo': microchipNo,
          if (isSpayedOrNeutered != null)
            'isSpayedOrNeutered': isSpayedOrNeutered,
          if (bloodType != null) 'bloodType': bloodType,
          if (color != null) 'color': color,
          if (allergies != null) 'allergies': allergies,
          if (chronicIllnesses != null) 'chronicIllnesses': chronicIllnesses,
        },
      );
      return PetModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan bilgileri güncellenemedi.');
    }
  }

  @override
  Future<String> updatePetPhoto(String id, String photoFilePath) async {
    try {
      final fileName = photoFilePath.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      MediaType? contentType;
      if (extension == 'jpg' || extension == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        contentType = MediaType('image', 'webp');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          photoFilePath,
          filename: fileName,
          contentType: contentType,
        ),
      });

      final response = await dio.post(
        '/pets/$id/photo',
        data: formData,
      );
      return response.data['photoUrl'] as String;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan fotoğrafı yüklenemedi.');
    }
  }

  @override
  Future<void> deletePetPhoto(String id) async {
    try {
      await dio.delete('/pets/$id/photo');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan fotoğrafı silinemedi.');
    }
  }

  @override
  Future<void> deletePet(String id) async {
    try {
      await dio.delete('/pets/$id');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Evcil hayvan kaydı silinemedi.');
    }
  }

  @override
  Future<List<PetWeightEntity>> getWeightHistory(String petId) async {
    try {
      final response = await dio.get('/pets/$petId/weight-history');
      final List<dynamic> historyJson = response.data;
      return historyJson.map((json) => PetWeightModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Kilo geçmişi alınamadı.');
    }
  }
}
