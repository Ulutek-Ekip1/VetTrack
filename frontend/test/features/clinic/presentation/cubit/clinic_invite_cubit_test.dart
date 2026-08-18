import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:vettrack_frontend/features/clinic/domain/entities/invite_validation_entity.dart';
import 'package:vettrack_frontend/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:vettrack_frontend/features/clinic/domain/usecases/accept_invite_usecase.dart';
import 'package:vettrack_frontend/features/clinic/domain/usecases/validate_invite_usecase.dart';
import 'package:vettrack_frontend/features/clinic/presentation/cubit/clinic_invite_cubit.dart';
import 'package:vettrack_frontend/features/clinic/presentation/cubit/clinic_invite_state.dart';

class MockClinicRepository implements ClinicRepository {
  bool shouldFailValidate = false;
  ServerException? validateException;
  InviteValidationEntity? mockValidationResponse;

  bool shouldFailAccept = false;
  ServerException? acceptException;
  int acceptCallCount = 0;
  String? lastAcceptedToken;

  @override
  Future<InviteValidationEntity> validateInviteToken(String token) async {
    if (shouldFailValidate) {
      throw validateException ?? const ServerException('Geçersiz kod', 404);
    }
    return mockValidationResponse ??
        const InviteValidationEntity(
          isValid: true,
          clinicName: 'Test Veteriner Kliniği',
          clinicId: 'clinic-123',
        );
  }

  @override
  Future<void> acceptInvite(String token) async {
    acceptCallCount++;
    lastAcceptedToken = token;
    if (shouldFailAccept) {
      throw acceptException ?? const ServerException('Kabul edilemedi', 400);
    }
  }
}

class MockAuthRepository implements AuthRepository {
  int registerCallCount = 0;
  bool shouldFailRegister = false;

  @override
  Future<UserEntity> register(
      String email, String password, String name, String? phone, UserRole role) async {
    registerCallCount++;
    if (shouldFailRegister) {
      throw const ServerException('E-posta zaten kullanımda', 409);
    }
    return UserEntity(
      id: 'user-123',
      authId: 'auth-123',
      email: email,
      name: name,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockClinicRepository mockClinicRepository;
  late MockAuthRepository mockAuthRepository;
  late ValidateInviteUseCase validateInviteUseCase;
  late AcceptInviteUseCase acceptInviteUseCase;
  late RegisterUseCase registerUseCase;
  late ClinicInviteCubit cubit;

  setUp(() {
    mockClinicRepository = MockClinicRepository();
    mockAuthRepository = MockAuthRepository();
    validateInviteUseCase = ValidateInviteUseCase(mockClinicRepository);
    acceptInviteUseCase = AcceptInviteUseCase(mockClinicRepository);
    registerUseCase = RegisterUseCase(mockAuthRepository);

    cubit = ClinicInviteCubit(
      validateInviteUseCase: validateInviteUseCase,
      acceptInviteUseCase: acceptInviteUseCase,
      registerUseCase: registerUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ClinicInviteCubit Tests', () {
    test('1. Boş token girildiğinde invalid hatası fırlatılmalıdır', () async {
      await cubit.validateToken('   ');
      expect(cubit.state, isA<ClinicInviteError>());
      final err = cubit.state as ClinicInviteError;
      expect(err.type, ClinicInviteErrorType.invalid);
    });

    test('2. Geçerli token doğrulandığında ClinicInviteValidated durumuna geçmelidir', () async {
      await cubit.validateToken('INV-VALID123');
      expect(cubit.state, isA<ClinicInviteValidated>());
      final validated = cubit.state as ClinicInviteValidated;
      expect(validated.clinicName, 'Test Veteriner Kliniği');
      expect(validated.token, 'INV-VALID123');
    });

    test('3. Süresi dolmuş token (410) ClinicInviteErrorType.expired döndürmelidir', () async {
      mockClinicRepository.shouldFailValidate = true;
      mockClinicRepository.validateException = const ServerException('Süresi dolmuş', 410);

      await cubit.validateToken('INV-EXPIRED');
      expect(cubit.state, isA<ClinicInviteError>());
      final err = cubit.state as ClinicInviteError;
      expect(err.type, ClinicInviteErrorType.expired);
    });

    test('4. Kullanılmış token (409) ClinicInviteErrorType.alreadyUsed döndürmelidir', () async {
      mockClinicRepository.shouldFailValidate = true;
      mockClinicRepository.validateException = const ServerException('Kullanılmış', 409);

      await cubit.validateToken('INV-USED');
      expect(cubit.state, isA<ClinicInviteError>());
      final err = cubit.state as ClinicInviteError;
      expect(err.type, ClinicInviteErrorType.alreadyUsed);
    });

    test('5. registerAndAccept akışı hem auth kaydını hem clinic kabulünü çalıştırmalıdır', () async {
      await cubit.registerAndAccept(
        email: 'dr.ahmet@klinik.com',
        password: 'password123',
        name: 'Dr. Ahmet Yılmaz',
        phone: '05551234567',
        token: 'INV-TOKEN-99',
        clinicName: 'Test Veteriner Kliniği',
      );

      expect(mockAuthRepository.registerCallCount, 1);
      expect(mockClinicRepository.acceptCallCount, 1);
      expect(mockClinicRepository.lastAcceptedToken, 'INV-TOKEN-99');
      expect(cubit.state, isA<ClinicInviteSuccess>());
      final success = cubit.state as ClinicInviteSuccess;
      expect(success.clinicName, 'Test Veteriner Kliniği');
    });

    test('6. registerAndAccept sırasında hata olursa acceptFailed tipiyle hata dönmelidir', () async {
      mockClinicRepository.shouldFailAccept = true;
      mockClinicRepository.acceptException = const ServerException('Bağlantı hatası', 500);

      await cubit.registerAndAccept(
        email: 'dr.mehmet@klinik.com',
        password: 'password123',
        name: 'Dr. Mehmet',
        token: 'INV-TOKEN-FAIL',
        clinicName: 'Test Veteriner Kliniği',
      );

      expect(cubit.state, isA<ClinicInviteError>());
      final err = cubit.state as ClinicInviteError;
      expect(err.type, ClinicInviteErrorType.acceptFailed);
      expect(err.token, 'INV-TOKEN-FAIL');
    });

    test('7. retryAcceptOnly sadece acceptInviteUseCase çağrısını tekrar denemelidir', () async {
      await cubit.retryAcceptOnly(
        token: 'INV-RETRY-123',
        clinicName: 'Test Kliniği',
      );

      expect(mockAuthRepository.registerCallCount, 0); // Yeniden register çağrılmaz
      expect(mockClinicRepository.acceptCallCount, 1);
      expect(cubit.state, isA<ClinicInviteSuccess>());
    });
  });
}
