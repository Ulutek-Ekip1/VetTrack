import '../entities/user_entity.dart';
import '../entities/owner_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> register(
      String email, String password, String name, String? phone, UserRole role);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> resendVerificationEmail();
  Future<OwnerEntity> getOwnerProfile();
  Future<OwnerEntity> updateOwnerProfile({
    String? name,
    String? surname,
    String? phone,
    String? address,
  });
  Future<UserEntity> signInWithGoogle();
}
