import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository authRepository;

  DeleteAccountCubit({required this.authRepository})
      : super(DeleteAccountInitial());

  Future<void> deleteAccount(String password) async {
    emit(DeleteAccountLoading());

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null || user.email == null) {
        emit(const DeleteAccountError('Kullanıcı bulunamadı.'));
        return;
      }

      // 1. Şifreyi Supabase'e doğrulat
      await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      // 2. Şifre doğruysa backend'e sadece JWT ile git
      await authRepository.deleteAccount();

      emit(DeleteAccountSuccess());
    } on AuthException catch (e) {
      if (e.statusCode == '400' || e.code == 'invalid_credentials') {
        emit(const DeleteAccountError('Şifre yanlış.'));
      } else {
        emit(DeleteAccountError(e.message));
      }
    } catch (e) {
      final message = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(DeleteAccountError(message));
    }
  }
}
