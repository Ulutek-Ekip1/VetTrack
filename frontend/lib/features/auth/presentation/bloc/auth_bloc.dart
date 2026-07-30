import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_entity.dart';

abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  LoginSubmittedEvent({
    required this.email,
    required this.password,
    required this.role,
  });
}

class LogoutSubmittedEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final AuthEntity user;
  AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(UnauthenticatedState()) {
    on<LoginSubmittedEvent>((event, emit) {
      emit(AuthLoadingState());
      final mockUser = AuthEntity(
        id: 'user_123',
        email: event.email,
        name: 'Kullanıcı',
        role: event.role,
      );
      emit(AuthenticatedState(mockUser));
    });

    on<LogoutSubmittedEvent>((event, emit) {
      emit(UnauthenticatedState());
    });
  }
}
