import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pets_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_state.dart';

class PetCubit extends Cubit<PetState> {
  final GetPetsUseCase getPetsUseCase;
  final AddPetUseCase addPetUseCase;
  final GetPetByIdUseCase getPetByIdUseCase;
  final UpdatePetUseCase updatePetUseCase;
  final UpdatePetPhotoUseCase updatePetPhotoUseCase;
  final DeletePetPhotoUseCase deletePetPhotoUseCase;
  final DeletePetUseCase deletePetUseCase;

  PetCubit({
    required this.getPetsUseCase,
    required this.addPetUseCase,
    required this.getPetByIdUseCase,
    required this.updatePetUseCase,
    required this.updatePetPhotoUseCase,
    required this.deletePetPhotoUseCase,
    required this.deletePetUseCase,
  }) : super(PetInitial());

  Future<void> fetchPets() async {
    emit(PetLoading());
    try {
      final pets = await getPetsUseCase.call();
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> addPet({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
    String? petPhotoUrl,
  }) async {
    emit(PetActionLoading());
    try {
      final newPet = await addPetUseCase.call(
        name: name,
        gender: gender,
        age: age,
        breed: breed,
      );
      if (petPhotoUrl != null) {
        await updatePetPhotoUseCase.call(photoPath: petPhotoUrl, id: newPet.id);
      }
      emit(const PetActionSuccess(message: 'Pet başarıyla eklendi'));
      fetchPets();
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }

  Future<void> getPetById({required String id}) async {
    emit(PetLoading());
    try {
      final pet = await getPetByIdUseCase.call(id: id);
      if (pet != null) {
        emit(PetLoaded(pets: [pet]));
      } else {
        emit(const PetError(message: 'Pet bulunamadı'));
      }
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> updatePet({
    required String id,
    String? name,
    Gender? gender,
    int? age,
    String? breed,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    emit(PetActionLoading());
    try {
      await updatePetUseCase.call(
        id: id,
        name: name,
        gender: gender,
        age: age,
        breed: breed,
      );

      if (removePhoto) {
        await deletePetPhotoUseCase.call(id: id);
      } else if (photoPath != null) {
        await updatePetPhotoUseCase.call(
          id: id,
          photoPath: photoPath,
        );
      }

      emit(const PetActionSuccess(message: 'Pet başarıyla güncellendi'));
      fetchPets();
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }

  Future<void> updatePetPhoto({
    required String id,
    required String photoPath,
  }) async {
    emit(PetActionLoading());
    try {
      await updatePetPhotoUseCase.call(
        id: id,
        photoPath: photoPath,
      );
      emit(const PetActionSuccess(message: 'Pet fotoğrafı güncellendi'));
      fetchPets();
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }

  Future<void> deletePet({required String id}) async {
    emit(PetActionLoading());
    try {
      await deletePetUseCase.call(id);
      emit(const PetActionSuccess(message: 'Pet silindi'));
      fetchPets();
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }
}
