import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message, errorMessage];
}
