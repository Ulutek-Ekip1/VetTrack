import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null || user.email == null) {
        emit(const DeleteAccountError('Kullanıcı bulunamadı.'));
        return;
      }

      final authResponse =
          await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      final newToken = authResponse.session?.accessToken;
      if (newToken != null) {
        await localDataSource.cacheToken(newToken);
      }

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
