import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository authRepository;

  DeleteAccountCubit({
    required this.authRepository,
  }) : super(DeleteAccountInitial());

  Future<void> deleteAccount(String password) async {
    emit(DeleteAccountLoading());

    try {
      final user = await authRepository.getCurrentUser();

      if (user == null || user.email.isEmpty) {
        emit(const DeleteAccountError('Kullanıcı bulunamadı.'));
        return;
      }

      // Re-authenticate with user email and password to obtain a fresh token
      try {
        await authRepository.loginWithEmail(user.email, password);
      } catch (e) {
        emit(const DeleteAccountError('Şifre yanlış.'));
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

