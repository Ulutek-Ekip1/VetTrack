import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<UserEntity> call(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    return await repository.loginWithEmail(
      email,
      password,
      rememberMe: rememberMe,
    );
  }
}
