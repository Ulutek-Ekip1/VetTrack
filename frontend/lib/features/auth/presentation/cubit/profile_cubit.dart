import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/entities/owner_entity.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/update_profile_photo_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/delete_profile_photo_usecase.dart';
import '../../domain/usecases/get_owner_profile_usecase.dart';
import '../../domain/usecases/update_owner_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetOwnerProfileUseCase getOwnerProfile;
  final UpdateOwnerProfileUseCase updateOwnerProfile;
  final UpdateProfilePhotoUseCase updateProfilePhotoUseCase;
  final DeleteProfilePhotoUseCase deleteProfilePhotoUseCase;

  ProfileCubit(
      {required this.getOwnerProfile,
      required this.updateOwnerProfile,
      required this.updateProfilePhotoUseCase,
      required this.deleteProfilePhotoUseCase})
      : super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await getOwnerProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> updateProfile({
    required String name,
    String? surname,
    String? phone,
    String? address,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));
      try {
        final updated = await updateOwnerProfile(
          name: name,
          surname: surname,
          phone: phone,
          address: address,
        );
        emit(ProfileUpdateSuccess(updated));
        // Reset to ProfileLoaded with updated values
        emit(ProfileLoaded(updated));
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
        // Revert back to loaded with current profile
        emit(ProfileLoaded(currentState.profile));
      }
    }
  }

  // Profil Fotoğrafı Yükle / Güncelle
  Future<void> uploadProfilePhoto(String newProfilPhotoUrl) async {
    final currentState = state;
    OwnerEntity? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    }
    emit(ProfileLoading());
    try {
      final newPhotoUrl =
          await updateProfilePhotoUseCase.call(newProfilPhotoUrl);
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          profilePhotoUrl: newPhotoUrl,
        );
        emit(ProfileLoaded(updatedProfile));
      } else {
        await fetchProfile();
      }
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
      if (currentProfile != null) {
        emit(ProfileLoaded(currentProfile));
      }
    }
  }

  // Profil Fotoğrafı Sil
  Future<void> deleteProfilePhoto() async {
    final currentState = state;
    OwnerEntity? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    }
    emit(ProfileLoading());
    try {
      await deleteProfilePhotoUseCase.call();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          profilePhotoUrl: null,
        );
        emit(ProfileLoaded(updatedProfile));
      } else {
        await fetchProfile();
      }
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
      if (currentProfile != null) {
        emit(ProfileLoaded(currentProfile));
      }
    }
  }
}
