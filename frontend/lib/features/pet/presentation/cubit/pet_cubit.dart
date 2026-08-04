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

  PetCubit({
    required this.getPetsUseCase,
    required this.addPetUseCase,
    required this.getPetByIdUseCase,
    required this.updatePetUseCase,
    required this.updatePetPhotoUseCase,
    required this.deletePetUseCase,
  }) : super(PetInitial()) {
    emit(PetLoaded(pets: [
      // Mock data for initial state
      PetEntity(
        id: 'pet_1',
        ownerId: '123',
        name: 'Karabaş',
        age: 3,
        gender: Gender.male,
        breed: 'Golden Retriever',
        uniqueCode: 'K-1234',
        photoUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=200&auto=format&fit=crop', // Örnek köpek resmi
        createdAt: DateTime.now(),
      ),
      PetEntity(
        id: 'pet_2',
        ownerId: '123',
        name: 'Luna',
        age: 1,
        gender: Gender.female,
        breed: 'Tekir',
        uniqueCode: 'L-5678',
        photoUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop', // Örnek kedi resmi
        createdAt: DateTime.now(),
      ),
    ]));
  }

  Future<void> fetchPets() async {
    emit(PetLoading());
    try {
      final pets = await getPetsUseCase.call();
      emit(PetLoaded(pets: pets));
    } catch (e) {
      // TODO: Gerçek hata yönetimini (production) tasarım testi için geçici olarak yorum satırına aldık:
      // emit(PetError(message: e.toString()));

      // Tasarım incelemesini engellememek için hata durumunda geçici olarak mock liste dönüyoruz:
      emit(PetLoaded(pets: [
        PetEntity(
          id: 'pet_1',
          ownerId: '123',
          name: 'Pamuk',
          age: 2,
          gender: Gender.female,
          breed: 'Tekir',
          uniqueCode: 'VT-9824',
          photoUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop',
          createdAt: DateTime.now(),
        ),
        PetEntity(
          id: 'pet_2',
          ownerId: '123',
          name: 'Gölge',
          age: 4,
          gender: Gender.male,
          breed: 'Golden Retriever',
          uniqueCode: 'VT-4129',
          photoUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=200&auto=format&fit=crop',
          createdAt: DateTime.now(),
        ),
      ]));
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
        name: name,
        gender: gender,
        age: age,
        breed: breed,
      );
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
