import 'package:equatable/equatable.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

abstract class PetState extends Equatable {
  const PetState();
  @override
  List<Object> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<PetEntity> pets;

  const PetLoaded({required this.pets});

  @override
  List<Object> get props => [pets];
}

class PetError extends PetState {
  final String message;

  const PetError({required this.message});

  @override
  List<Object> get props => [message];
}

class PetActionLoading extends PetState {}

class PetActionSuccess extends PetState {
  final String message;

  const PetActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PetActionError extends PetState {
  final String message;

  const PetActionError({required this.message});

  @override
  List<Object> get props => [message];
}
