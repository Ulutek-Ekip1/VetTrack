import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_state.dart';

class PetCubit extends Cubit<PetState> {
  final PetRepository petRepository;

  PetCubit({required this.petRepository}) : super(PetInitial());

  Future<void> fetchPets() async {
    emit(PetLoading());
    try {
      final pets = await petRepository.getPets();
      emit(PetLoaded(pets: pets));
    } catch (e) {
      emit(PetError(message: e.toString()));
    }
  }
}
