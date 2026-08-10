import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signin_with_google_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase loginWithEmail;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginWithEmail,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.signInWithGoogleUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser().timeout(
            const Duration(seconds: 15),
            onTimeout: () => null,
          );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthLoading());

    try {
      final user = await loginWithEmail(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogleUseCase();
      if (user.id.isEmpty) {
        emit(AuthInitial());
        return;
      }
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signUp(String email, String password, String name, String? phone,
      UserRole role) async {
    emit(const AuthLoading());
    try {
      final user = await registerUseCase(email, password, name, phone, role);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());
    try {
      final cleanEmail = email.trim();
      if (cleanEmail.isEmpty || !cleanEmail.contains("@")) {
        throw Exception("Lütfen geçerli bir e-posta adresi giriniz.");
      }
      // Gerçek repository veya mock şifre sıfırlama işlemi
      await Future.delayed(const Duration(milliseconds: 800));
      emit(PasswordResetEmailSent(cleanEmail));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> resendVerificationEmail() async {
    emit(const AuthLoading());
    try {
      await authRepository.resendVerificationEmail();
      emit(const VerificationEmailSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //Oturum süresi dolunca yerel tokenı silip uygulmayı unauthenticated duruma geçirmek için
  Future<void> handleSessionExpired() async {
    await logoutUseCase();
    emit(const Unauthenticated(
        'Oturumunuzun süresi doldu, lütfen tekrar giriş yapın.'));
  }
}
