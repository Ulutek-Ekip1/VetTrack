import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pets_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_state.dart';

class PetCubit extends Cubit<PetState> {
  final GetPetsUseCase getPetsUseCase;
  final AddPetUseCase addPetUseCase;
  final GetPetByIdUseCase getPetByIdUseCase;
  final UpdatePetUseCase updatePetUseCase;
  final UpdatePetPhotoUseCase updatePetPhotoUseCase;
  final DeletePetUseCase deletePetUseCase;
  //final GetPetVisitsUseCase getPetVisitsUseCase;
  //final GetPetRecommendationsUseCase getPetRecommendationsUseCase;

  PetCubit(
      {required this.getPetsUseCase,
      required this.addPetUseCase,
      required this.getPetByIdUseCase,
      required this.updatePetUseCase,
      required this.updatePetPhotoUseCase,
      required this.deletePetUseCase})
      : super(PetInitial());

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
  }) async {
    emit(PetActionLoading());
    try {
      await addPetUseCase.call(
        // ileri de bunu petactionSuccess ile uı tarafına gönderilebilir.
        //Şu anda sadece geri dönen değeri tutuyor listeyi sunucudan güncelliyoruz.
        name: name,
        gender: gender,
        age: age,
        breed: breed,
      );
      emit(const PetActionSuccess(message: 'Pet added successfully'));
      fetchPets(); // Refresh the list of pets after adding a new one
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
        emit(const PetError(message: 'Pet not found'));
      }
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }

  Future<void> updatePet({
    required String id,
    String? name,
    Gender? gender,
  }) async {
    emit(PetActionLoading());
    try {
      await updatePetUseCase.call(
        id: id,
        name: name,
        gender: gender,
      );
      emit(const PetActionSuccess(message: 'Pet updated successfully'));
      fetchPets(); // Refresh the list of pets after updating
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
      emit(const PetActionSuccess(message: 'Pet photo updated successfully'));
      fetchPets(); // Refresh the list of pets after updating the photo
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }
  Future<void> deletePet({required String id}) async {
    emit(PetActionLoading());
    try {
      await deletePetUseCase.call(id: id);
      emit(const PetActionSuccess(message: 'Evcil hayvan başarıyla silindi'));
      fetchPets(); // Silme işleminden sonra listeyi güncelle
    } catch (e) {
      emit(PetActionError(message: e.toString()));
    }
  }
}
