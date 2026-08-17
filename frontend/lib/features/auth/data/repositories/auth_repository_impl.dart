import '../../domain/entities/user_entity.dart';
import '../../domain/entities/owner_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> loginWithEmail(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    return await remoteDataSource.loginWithEmail(
      email,
      password,
      rememberMe: rememberMe,
    );
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
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await remoteDataSource.reSendVerificationEmail(email);
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

  @override
  Future<String> updateProfilePhoto(String filePath) async {
    return await remoteDataSource.updateProfilPhoto(filePath);
  }

  @override
  Future<void> deleteProfilePhoto() async {
    await remoteDataSource.deleteProfilPhoto();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
  }
}
