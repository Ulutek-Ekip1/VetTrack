import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository authRepository;

  DeleteAccountCubit({required this.authRepository})
      : super(DeleteAccountInitial());

  Future<void> deleteAccount(String password) async {
    emit(DeleteAccountLoading());
    try {
      await authRepository.deleteAccount(password);
      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountError(e.toString()));
    }
  }
}
