import '../../domain/entities/user_entity.dart';
import '../../domain/entities/owner_entity.dart';
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
  Future<UserEntity> register(String email, String password, String name,
      String? phone, UserRole role) async {
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

  @override
  Future<void> resendVerificationEmail() async {
    // TODO: Backend bağlandığında remoteDataSource üzerinden e-posta gönderimini tetikle
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<OwnerEntity> getOwnerProfile() async {
    return await remoteDataSource.getOwnerProfile();
  }

  @override
  Future<OwnerEntity> updateOwnerProfile({
    String? name,
    String? surname,
    String? phone,
    String? address,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (surname != null) data['surname'] = surname;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    return await remoteDataSource.updateOwnerProfile(data);
  }
}
