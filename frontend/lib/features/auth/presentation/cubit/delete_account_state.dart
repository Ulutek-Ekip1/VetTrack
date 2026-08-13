import 'package:equatable/equatable.dart';

class DeleteAccountState extends Equatable {
  const DeleteAccountState();
  @override
  List<Object?> get props => [];
}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountError extends DeleteAccountState {
  final String message;

  const DeleteAccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteAccountLoading extends DeleteAccountState {}
