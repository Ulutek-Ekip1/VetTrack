import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase loginWithEmail;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginWithEmail,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthLoading());

    try {
      final user = await loginWithEmail(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String name, String? phone,
      UserRole role) async {
    emit(const AuthLoading());
    try {
      final user = await registerUseCase(email, password, name, phone, role);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

