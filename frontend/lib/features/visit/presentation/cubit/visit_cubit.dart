import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/start_visit_usecase.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/close_visit_usecase.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/search_by_code_usecase.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';

class VisitCubit extends Cubit<VisitState> {
  final SearchByCodeUseCase searchByCodeUseCase;
  final StartVisitUseCase startVisitUseCase;
  final CloseVisitUseCase closeVisitUseCase;
  final VisitRepository repository;

  VisitCubit({
    required this.searchByCodeUseCase,
    required this.startVisitUseCase,
    required this.closeVisitUseCase,
    required this.repository,
  }) : super(VisitInitial());

  Future<void> searchByCode(String code) async {
    emit(VisitLoading());
    try {
      final result = await searchByCodeUseCase(code);
      emit(VisitSearchResult(result));
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> startVisit(String petId) async {
    emit(VisitLoading());
    try {
      final visit = await startVisitUseCase(petId);
      emit(VisitStarted(visit));
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> closeVisit(String visitId) async {
    emit(VisitLoading());
    try {
      await closeVisitUseCase(visitId);
      emit(VisitClosed());
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchOwnerVisitHistory() async {
    emit(VisitLoading());
    try {
      final visits = await repository.getOwnerVisitHistory();
      emit(VisitHistoryLoaded(visits));
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchVetVisitHistory() async {
    emit(VisitLoading());
    try {
      final visits = await repository.getVetVisitHistory();
      emit(VisitHistoryLoaded(visits));
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchPetVisitHistory(String petId) async {
    emit(VisitLoading());
    try {
      final visits = await repository.getPetVisitHistory(petId);
      emit(VisitHistoryLoaded(visits));
    } catch (e) {
      emit(VisitError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
