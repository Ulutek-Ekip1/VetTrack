import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_recommendation_usecase.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final AddRecommendationUseCase addRecommendationUseCase;
  final GetRecommendationsUseCase getRecommendationsUseCase;

  RecommendationCubit({
    required this.addRecommendationUseCase,
    required this.getRecommendationsUseCase,
  }) : super(RecommendationInitial());

  Future<void> loadRecommendations(String petId) async {
    emit(RecommendationLoading());

    try {
      final recommendations = await getRecommendationsUseCase(petId);
      emit(RecommendationLoaded(recommendations));
    } catch (e) {
      emit(RecommendationError("Öneriler yüklenemedi: ${e.toString()}"));
    }
  }

  Future<void> addRecommendation({
    required String visitId,
    required String type,
    required String description,
  }) async {
    emit(RecommendationLoading());

    try {
      await addRecommendationUseCase(
        visitId: visitId,
        type: type,
        description: description,
      );
      emit(const RecommendationActionSuccess("Öneri başarı ile eklendi."));
    } catch (e) {
      emit(RecommendationError("Öneri eklenemedi: ${e.toString()}"));
    }
  }
}
