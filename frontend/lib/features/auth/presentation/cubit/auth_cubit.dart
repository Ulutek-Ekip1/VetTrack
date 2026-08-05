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
    emit(AuthLoading());
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
    emit(AuthLoading());
    try {
      final user = await loginWithEmail(email, password);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await registerDeviceTokenUseCase(
            fcmToken: fcmToken, platform: 'android');
      }
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String name, String? phone,
      UserRole role) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(email, password, name, phone, role);
      await sl<FirebaseMessagingService>().sendTokenToBackend();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await sl<FirebaseMessagingService>().removeTokenFromBackend();
      }
      await logoutUseCase();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
