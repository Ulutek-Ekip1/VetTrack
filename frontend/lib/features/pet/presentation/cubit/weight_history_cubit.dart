import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_weight_history_usecase.dart';
import 'weight_history_state.dart';

class WeightHistoryCubit extends Cubit<WeightHistoryState> {
  final GetWeightHistoryUseCase getWeightHistoryUseCase;

  WeightHistoryCubit({required this.getWeightHistoryUseCase})
      : super(WeightHistoryInitial());

  Future<void> fetchWeightHistory(String petId) async {
    emit(WeightHistoryLoading());
    try {
      final history = await getWeightHistoryUseCase.call(petId);
      emit(WeightHistoryLoaded(history));
    } catch (e) {
      emit(WeightHistoryError(e.toString()));
    }
  }
}
