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
        emit(const DeleteAccountError('Oturum açmış kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'));
        return;
      }

      // Şifreyi doğrula ve taze token al (Spring Boot re-authentication)
      try {
        await authRepository.loginWithEmail(user.email, password);
      } catch (e) {
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        if (msg.contains('hatalı') || msg.contains('401') || msg.contains('password')) {
          emit(const DeleteAccountError('Şifre yanlış. Lütfen kontrol edip tekrar deneyin.'));
        } else {
          emit(DeleteAccountError(msg));
        }
        return;
      }

      // Taze token ile hesap silme isteğini gönder
      await authRepository.deleteAccount();

      emit(DeleteAccountSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(DeleteAccountError(message));
    }
  }
}
