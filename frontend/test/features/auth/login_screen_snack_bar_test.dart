import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:vettrack_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/signin_with_google_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/core/theme/app_theme.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/unregister_device_token_usecase.dart';

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit(super.initialState);

  @override
  late final LoginWithEmailUseCase loginWithEmail;
  @override
  late final RegisterUseCase registerUseCase;
  @override
  late final LogoutUseCase logoutUseCase;
  @override
  late final SignInWithGoogleUseCase signInWithGoogleUseCase;
  @override
  late final AuthRepository authRepository;

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signUp(String email, String password, String name, String? phone,
      dynamic role) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> resendVerificationEmail(String email) async {}

  @override
  Future<void> handleSessionExpired() async {}

  void triggerError(String errorMessage) {
    emit(AuthError(errorMessage));
  }

  @override
  // TODO: implement registerDeviceTokenUseCase
  RegisterDeviceTokenUseCase get registerDeviceTokenUseCase =>
      throw UnimplementedError();

  @override
  // TODO: implement unregisterDeviceTokenUseCase
  UnregisterDeviceTokenUseCase get unregisterDeviceTokenUseCase =>
      throw UnimplementedError();

  @override
  // TODO: implement forgotPasswordUseCase
  ForgotPasswordUseCase get forgotPasswordUseCase => throw UnimplementedError();

  @override
  // TODO: implement resendVerificationEmailUsecase
  ResendVerificationEmailUsecase get resendVerificationEmailUsecase =>
      throw UnimplementedError();
}

void main() {
  late FakeAuthCubit fakeAuthCubit;

  setUp(() {
    fakeAuthCubit = FakeAuthCubit(const Unauthenticated());
  });

  Widget createWidgetToTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AuthCubit>.value(
        value: fakeAuthCubit,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('Test 1: 401 Hatalı e-posta veya şifre SnackBar gösterimi',
      (tester) async {
    await tester.pumpWidget(createWidgetToTest());
    await tester.pump();

    // Trigger 401 AuthError
    fakeAuthCubit.triggerError("E-posta veya şifre hatalı");
    await tester.pump(); // trigger listener
    await tester.pump(const Duration(milliseconds: 300)); // animation pump

    // Assert SnackBar Title & Message
    expect(find.text('Giriş Engellendi'), findsOneWidget);
    expect(find.text('E-posta veya şifre hatalı'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('Test 2: 429 Çok fazla hatalı deneme SnackBar gösterimi',
      (tester) async {
    await tester.pumpWidget(createWidgetToTest());
    await tester.pump();

    // Trigger Rate Limit AuthError
    fakeAuthCubit.triggerError(
        "Çok fazla hatalı deneme yaptınız. Lütfen 5 dakika sonra tekrar deneyin.");
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Assert SnackBar Title & Message
    expect(find.text('Giriş Engellendi'), findsOneWidget);
    expect(
        find.text(
            'Çok fazla hatalı deneme yaptınız. Lütfen 5 dakika sonra tekrar deneyin.'),
        findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('Test 3: Bağlantı hatası SnackBar gösterimi', (tester) async {
    await tester.pumpWidget(createWidgetToTest());
    await tester.pump();

    // Trigger Network AuthError
    fakeAuthCubit.triggerError("Bilinmeyen bağlantı hatası");
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Assert SnackBar Title & Message
    expect(find.text('Bağlantı Hatası'), findsOneWidget);
    expect(find.text('Bilinmeyen bağlantı hatası'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });
}
