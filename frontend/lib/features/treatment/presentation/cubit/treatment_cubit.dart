import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_treatment_usecase.dart';
import '../../domain/usecases/delete_treatment_usecase.dart';
import '../../domain/usecases/get_treatment_usecase.dart';
import '../../domain/repositories/treatment_repository.dart';
import 'treatment_state.dart';

class TreatmentCubit extends Cubit<TreatmentState> {
  final AddTreatmentUseCase addTreatmentUseCase;
  final GetTreatmentUseCase getTreatmentUseCase;
  final DeleteTreatmentUseCase deleteTreatmentUseCase;
  final TreatmentRepository repository;

  TreatmentCubit({
    required this.addTreatmentUseCase,
    required this.getTreatmentUseCase,
    required this.deleteTreatmentUseCase,
    required this.repository,
  }) : super(TreatmentInitial());

  Future<void> loadTreatments(String visitId) async {
    emit(TreatmentLoading());

    try {
      final treatments = await getTreatmentUseCase(visitId);
      emit(TreatmentLoaded(treatments));
    } catch (e) {
      emit(TreatmentError(e.toString()));
    }
  }

  Future<void> loadPetTreatments(String petId) async {
    emit(TreatmentLoading());

    try {
      final treatments = await repository.getPetTreatments(petId);
      emit(TreatmentLoaded(treatments));
    } catch (e) {
      emit(TreatmentError(e.toString()));
    }
  }

  Future<void> addTreatment({
    required String visitId,
    required String type,
    required String title,
    String? description,
    String? attachmentUrl,
  }) async {
    emit(TreatmentLoading());

    try {
      await addTreatmentUseCase(
        visitId: visitId,
        type: type,
        title: title,
        description: description,
        attachmentUrl: attachmentUrl,
      );
      emit(const TreatmentActionSuccess("Tedavi başarı ile eklendi."));
    } catch (e) {
      emit(TreatmentError(e.toString()));
    }
  }

  Future<void> deleteTreatment(String treatmentId) async {
    emit(TreatmentDeleting());

    try {
      await deleteTreatmentUseCase(treatmentId);
      emit(const TreatmentDeletedSuccess("Tedavi silindi."));
    } catch (e) {
      emit(TreatmentError(e.toString()));
    }
  }
}
