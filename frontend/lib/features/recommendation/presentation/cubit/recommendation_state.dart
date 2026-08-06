import 'package:equatable/equatable.dart';
import 'package:vettrack_frontend/features/recommendation/domain/entities/recommendation_entity.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<RecommendationEntity> recommendations;

  const RecommendationLoaded(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class RecommendationActionSuccess extends RecommendationState {
  final String message;

  const RecommendationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object?> get props => [message];
}
