import 'package:equatable/equatable.dart';
import '../../domain/entities/pet_entity.dart';

abstract class WeightHistoryState extends Equatable {
  const WeightHistoryState();
  @override
  List<Object?> get props => [];
}

class WeightHistoryInitial extends WeightHistoryState {}

class WeightHistoryLoading extends WeightHistoryState {}

class WeightHistoryLoaded extends WeightHistoryState {
  final List<PetWeightEntity> history;
  const WeightHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class WeightHistoryError extends WeightHistoryState {
  final String message;
  const WeightHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
