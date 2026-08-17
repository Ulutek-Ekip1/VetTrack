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

class Unauthenticated extends AuthState {
  const Unauthenticated([String? message]) : super(errorMessage: message);
}

class PasswordResetEmailSent extends AuthState {
  final String email;
  const PasswordResetEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message, errorMessage];
}

class VerificationEmailSent extends AuthState {
  final String? email;
  const VerificationEmailSent([this.email]);

  @override
  List<Object?> get props => [email];
}

class RegistrationSuccess extends AuthState {
  const RegistrationSuccess();
}
