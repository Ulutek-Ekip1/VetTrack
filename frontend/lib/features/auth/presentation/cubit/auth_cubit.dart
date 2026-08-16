import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../notification/domain/usecases/register_device_token_usecase.dart';
import '../../../notification/domain/usecases/unregister_device_token_usecase.dart';
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
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResendVerificationEmailUsecase resendVerificationEmailUsecase;
  int _sessionOperation = 0;

  AuthCubit(
      {required this.loginWithEmail,
      required this.registerUseCase,
      required this.logoutUseCase,
      required this.signInWithGoogleUseCase,
      required this.authRepository,
      required this.registerDeviceTokenUseCase,
      required this.unregisterDeviceTokenUseCase,
      required this.forgotPasswordUseCase,
      required this.resendVerificationEmailUsecase})
      : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final operation = ++_sessionOperation;
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser().timeout(
            const Duration(seconds: 15),
            onTimeout: () => null,
          );
      if (operation != _sessionOperation) return;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      if (operation != _sessionOperation) return;
      emit(const Unauthenticated());
    }
  }

  Future<void> signInWithEmail(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    final operation = ++_sessionOperation;
    emit(const AuthLoading());

    try {
      final user = await loginWithEmail(
        email,
        password,
        rememberMe: rememberMe,
      );
      if (operation != _sessionOperation) return;
      try {
        if (user.role == UserRole.owner) {
          sl<FirebaseMessagingService>().listenForTokenChanges();
        }
      } catch (fcmError) {
        // Hata yutulur, kullanıcının giriş yapması engellenmez.
      }
      emit(Authenticated(user));
    } catch (e) {
      if (operation != _sessionOperation) return;
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signInWithGoogle() async {
    final operation = ++_sessionOperation;
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogleUseCase();
      if (operation != _sessionOperation) return;
      if (user.id.isEmpty) {
        emit(AuthInitial());
        return;
      }
      emit(Authenticated(user));
    } catch (e) {
      if (operation != _sessionOperation) return;
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signUp(String email, String password, String name, String? phone,
      UserRole role) async {
    final operation = ++_sessionOperation;
    emit(const AuthLoading());
    try {
      final user = await registerUseCase(email, password, name, phone, role);
      if (operation != _sessionOperation) return;
      try {
        if (user.role == UserRole.owner) {
          sl<FirebaseMessagingService>().listenForTokenChanges();
        }
      } catch (fcmError) {
        // Hata yutulur
      }
      emit(const RegistrationSuccess());
    } catch (e) {
      if (operation != _sessionOperation) return;
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signOut() async {
    final operation = ++_sessionOperation;
    emit(const AuthLoading());
    try {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sl<FirebaseMessagingService>().removeTokenFromBackend();
        }
      } catch (_) {
        // FCM token silme işlemi başarsız olsa bile (örneğin sunucuya ulaşılamıyor),
        // kullanıcının çıkış yapmasını engellememek için hatayı yutuyoruz.
      }
      await logoutUseCase();
      if (operation != _sessionOperation) return;
      emit(const Unauthenticated());
    } catch (e) {
      if (operation != _sessionOperation) return;
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
      await forgotPasswordUseCase(cleanEmail);
      emit(PasswordResetEmailSent(cleanEmail));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    emit(const AuthLoading());
    try {
      await resendVerificationEmailUsecase(email);
      emit(const VerificationEmailSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //Oturum süresi dolunca yerel tokenı silip uygulmayı unauthenticated duruma geçirmek için
  Future<void> handleSessionExpired() async {
    ++_sessionOperation;
    await logoutUseCase();
    emit(const Unauthenticated(
        'Oturumunuzun süresi doldu, lütfen tekrar giriş yapın.'));
  }
}
