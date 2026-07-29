import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    return await remoteDataSource.loginWithEmail(email, password);
  }

  @override
  Future<UserEntity> register(String email, String password, String name, String? phone, UserRole role) async {
    return await remoteDataSource.register(email, password, name, phone, role);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }
}
