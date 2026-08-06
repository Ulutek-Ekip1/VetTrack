import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_owner_profile_usecase.dart';
import '../../domain/usecases/update_owner_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetOwnerProfileUseCase getOwnerProfile;
  final UpdateOwnerProfileUseCase updateOwnerProfile;

  ProfileCubit({
    required this.getOwnerProfile,
    required this.updateOwnerProfile,
  }) : super(ProfileInitial());

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
}
