import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../notification/domain/usecases/register_device_token_usecase.dart';
import '../../../notification/domain/usecases/unregister_device_token_usecase.dart';
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
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase;

  AuthCubit({
    required this.loginWithEmail,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
    required this.registerDeviceTokenUseCase,
    required this.unregisterDeviceTokenUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser().timeout(
            const Duration(seconds: 3),
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
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await registerDeviceTokenUseCase(
            fcmToken: fcmToken, platform: 'android');
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
      await sl<FirebaseMessagingService>().sendTokenToBackend();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> signOut() async {
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
      emit(const Unauthenticated());
    } catch (e) {
      // Local logout (logoutUseCase) başarısız olursa
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
