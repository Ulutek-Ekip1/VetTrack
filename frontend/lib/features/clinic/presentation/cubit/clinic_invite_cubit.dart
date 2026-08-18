import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/register_usecase.dart';
import '../../domain/usecases/accept_invite_usecase.dart';
import '../../domain/usecases/validate_invite_usecase.dart';
import 'clinic_invite_state.dart';

class ClinicInviteCubit extends Cubit<ClinicInviteState> {
  final ValidateInviteUseCase validateInviteUseCase;
  final AcceptInviteUseCase acceptInviteUseCase;
  final RegisterUseCase registerUseCase;

  ClinicInviteCubit({
    required this.validateInviteUseCase,
    required this.acceptInviteUseCase,
    required this.registerUseCase,
  }) : super(const ClinicInviteInitial());

  void reset() {
    emit(const ClinicInviteInitial());
  }

  Future<void> validateToken(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) {
      emit(const ClinicInviteError(
        message: 'Lütfen bir davet kodu giriniz.',
        type: ClinicInviteErrorType.invalid,
      ));
      return;
    }

    emit(const ClinicInviteValidating());

    try {
      final result = await validateInviteUseCase(cleanToken);

      if (result.isValid) {
        emit(ClinicInviteValidated(
          clinicName: result.clinicName,
          token: cleanToken,
          clinicId: result.clinicId,
        ));
      } else {
        emit(ClinicInviteError(
          message: 'Davet kodu geçerli değil veya süresi dolmuş.',
          type: ClinicInviteErrorType.invalid,
          token: cleanToken,
        ));
      }
    } on ServerException catch (e) {
      ClinicInviteErrorType errType = ClinicInviteErrorType.unknown;
      if (e.statusCode == 404) {
        errType = ClinicInviteErrorType.invalid;
      } else if (e.statusCode == 410) {
        errType = ClinicInviteErrorType.expired;
      } else if (e.statusCode == 409) {
        errType = ClinicInviteErrorType.alreadyUsed;
      } else if (e.statusCode == null) {
        errType = ClinicInviteErrorType.network;
      }

      emit(ClinicInviteError(
        message: e.message ?? 'Davet kodu doğrulanamadı.',
        type: errType,
        token: cleanToken,
      ));
    } catch (e) {
      emit(ClinicInviteError(
        message: 'Beklenmeyen bir hata oluştu: $e',
        type: ClinicInviteErrorType.unknown,
        token: cleanToken,
      ));
    }
  }

  Future<void> registerAndAccept({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String token,
    required String clinicName,
  }) async {
    emit(const ClinicInviteSubmitting());

    try {
      // 1. Standart hesap kaydı oluşturulur (Supabase Auth & Profiles)
      await registerUseCase(
        email.trim(),
        password,
        name.trim(),
        phone?.trim(),
        UserRole.owner, // Public auth kısıtını karşılar
      );

      // 2. Hesaba klinik üyeliği bağlanır (clinic_memberships)
      await acceptInviteUseCase(token.trim());

      emit(ClinicInviteSuccess(
        clinicName: clinicName,
        token: token.trim(),
      ));
    } on ServerException catch (e) {
      emit(ClinicInviteError(
        message: e.message ?? 'Klinik üyeliği tamamlanamadı.',
        type: ClinicInviteErrorType.acceptFailed,
        token: token.trim(),
        clinicName: clinicName,
      ));
    } catch (e) {
      emit(ClinicInviteError(
        message: 'Kayıt sırasında hata oluştu: $e',
        type: ClinicInviteErrorType.acceptFailed,
        token: token.trim(),
        clinicName: clinicName,
      ));
    }
  }

  Future<void> retryAcceptOnly({
    required String token,
    required String clinicName,
  }) async {
    emit(const ClinicInviteSubmitting());

    try {
      await acceptInviteUseCase(token.trim());
      emit(ClinicInviteSuccess(
        clinicName: clinicName,
        token: token.trim(),
      ));
    } catch (e) {
      emit(ClinicInviteError(
        message: 'Kliniğe bağlanırken hata oluştu. Lütfen tekrar deneyiniz.',
        type: ClinicInviteErrorType.acceptFailed,
        token: token.trim(),
        clinicName: clinicName,
      ));
    }
  }
}
