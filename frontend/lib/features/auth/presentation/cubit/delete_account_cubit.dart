import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/data/datasources/token_local_data_source.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository authRepository;
  final TokenLocalDataSource localDataSource;

  DeleteAccountCubit({
    required this.authRepository,
    required this.localDataSource,
  }) : super(DeleteAccountInitial());

  Future<void> deleteAccount(String password) async {
    emit(DeleteAccountLoading());

    try {
      final user = await authRepository.getCurrentUser();

      if (user == null || user.email.isEmpty) {
        emit(const DeleteAccountError('Kullanıcı bulunamadı.'));
        return;
      }

      // Read current rememberMe preference so re-auth preserves the session configuration
      final isRememberMe = await localDataSource.isRememberMe();

      // Re-authenticate with user email and password
      try {
        await authRepository.loginWithEmail(
          user.email,
          password,
          rememberMe: isRememberMe,
        );
      } catch (e) {
        final errorMsg =
            e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (errorMsg.contains('E-posta veya şifre hatalı') ||
            errorMsg.contains('401')) {
          emit(const DeleteAccountError('Şifre yanlış.'));
        } else {
          emit(DeleteAccountError(errorMsg));
        }
        return;
      }

      await authRepository.deleteAccount();

      emit(DeleteAccountSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(DeleteAccountError(message));
    }
  }
}

