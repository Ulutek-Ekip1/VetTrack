import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_treatment_usecase.dart';
import '../../domain/usecases/delete_treatment_usecase.dart';
import '../../domain/usecases/get_treatment_usecase.dart';
import 'treatment_state.dart';

class TreatmentCubit extends Cubit<TreatmentState> {
  final AddTreatmentUseCase addTreatmentUseCase;
  final GetTreatmentUseCase getTreatmentUseCase;
  final DeleteTreatmentUseCase deleteTreatmentUseCase;

  TreatmentCubit({
    required this.addTreatmentUseCase,
    required this.getTreatmentUseCase,
    required this.deleteTreatmentUseCase,
  }) : super(TreatmentInitial());

  Future<void> loadTreatment(String visitId) async {
    emit(TreatmentLoading());

    try {
      final treatments = await getTreatmentUseCase(visitId);
      emit(TreatmentLoaded(treatments));
    } catch (e) {
      emit(TreatmentError(e.toString()));
    }
  }

  Future<void> addTreatment(dynamic treatment) async {
    emit(TreatmentLoading());

    try {
      await addTreatmentUseCase(treatment);
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
