import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/network/auth_interceptor.dart';
import 'package:vettrack_frontend/features/auth/data/datasources/token_local_data_source.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/signin_with_google_usecase.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/unregister_device_token_usecase.dart';

class MockTokenLocalDataSource implements TokenLocalDataSource {
  String? token = 'mock-jwt-token';
  bool deleteTokenCalled = false;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> cacheToken(String token, {bool persist = true}) async {
    this.token = token;
  }

  @override
  Future<void> deleteToken() async {
    deleteTokenCalled = true;
    token = null;
  }
}

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit() : super(AuthInitial());

  int sessionExpiredCallCount = 0;

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
  late final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  @override
  late final UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase;
  @override
  late final ForgotPasswordUseCase forgotPasswordUseCase;
  @override
  late final ResendVerificationEmailUsecase resendVerificationEmailUsecase;

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> signInWithEmail(String email, String password, {bool rememberMe = false}) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signUp(String email, String password, String name, String? phone, dynamic role) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> resendVerificationEmail(String email) async {}

  @override
  Future<void> handleSessionExpired() async {
    sessionExpiredCallCount++;
  }
}

class FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? nextError;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void reject(DioException err, [bool? silent]) {
    nextError = err;
  }

  @override
  void resolve(Response response) {}
}

class FakeRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextOptions = requestOptions;
  }
}

void main() {
  late MockTokenLocalDataSource mockTokenLocalDataSource;
  late FakeAuthCubit fakeAuthCubit;
  late AuthInterceptor interceptor;

  setUp(() {
    mockTokenLocalDataSource = MockTokenLocalDataSource();
    fakeAuthCubit = FakeAuthCubit();
    interceptor = AuthInterceptor(
      mockTokenLocalDataSource,
      () => fakeAuthCubit,
    );
  });

  group('AuthInterceptor Tests', () {
    test('1. Public auth isteklerinde Authorization header eklenmez', () async {
      final options = RequestOptions(path: '/auth/login');
      final handler = FakeRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
    });

    test('2. Korumalı isteklerde token varsa Authorization header eklenir', () async {
      final options = RequestOptions(path: '/visits/vet');
      final handler = FakeRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer mock-jwt-token');
    });

    test('3. Yetkili korumalı istekte 401 UNAUTHORIZED gelirse handleSessionExpired tetiklenir', () {
      final err = DioException(
        requestOptions: RequestOptions(
          path: '/visits/vet',
          headers: {'Authorization': 'Bearer mock-jwt-token'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/visits/vet'),
          statusCode: 401,
          data: {'status': 401, 'error': 'UNAUTHORIZED', 'message': 'Token expired'},
        ),
      );
      final handler = FakeErrorInterceptorHandler();

      interceptor.onError(err, handler);

      expect(fakeAuthCubit.sessionExpiredCallCount, 1);
      expect(handler.nextError, isNotNull);
    });

    test('4. 401 REAUTHENTICATION_REQUIRED geldiğinde handleSessionExpired tetiklenmemelidir', () {
      final err = DioException(
        requestOptions: RequestOptions(
          path: '/auth/me',
          headers: {'Authorization': 'Bearer mock-jwt-token'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
          data: {'status': 401, 'error': 'REAUTHENTICATION_REQUIRED'},
        ),
      );
      final handler = FakeErrorInterceptorHandler();

      interceptor.onError(err, handler);

      expect(fakeAuthCubit.sessionExpiredCallCount, 0);
      expect(handler.nextError, isNotNull);
    });

    test('5. 401 EMAIL_NOT_VERIFIED geldiğinde handleSessionExpired tetiklenmemelidir', () {
      final err = DioException(
        requestOptions: RequestOptions(
          path: '/visits/vet',
          headers: {'Authorization': 'Bearer mock-jwt-token'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/visits/vet'),
          statusCode: 401,
          data: {'status': 401, 'error': 'EMAIL_NOT_VERIFIED'},
        ),
      );
      final handler = FakeErrorInterceptorHandler();

      interceptor.onError(err, handler);

      expect(fakeAuthCubit.sessionExpiredCallCount, 0);
      expect(handler.nextError, isNotNull);
    });

    test('6. 403 FORBIDDEN geldiğinde handleSessionExpired tetiklenmemelidir', () {
      final err = DioException(
        requestOptions: RequestOptions(
          path: '/visits/vet',
          headers: {'Authorization': 'Bearer mock-jwt-token'},
        ),
        response: Response(
          requestOptions: RequestOptions(path: '/visits/vet'),
          statusCode: 403,
          data: {'status': 403, 'error': 'FORBIDDEN'},
        ),
      );
      final handler = FakeErrorInterceptorHandler();

      interceptor.onError(err, handler);

      expect(fakeAuthCubit.sessionExpiredCallCount, 0);
      expect(handler.nextError, isNotNull);
    });
  });
}
