import '../entities/owner_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateOwnerProfileUseCase {
  final AuthRepository repository;

  UpdateOwnerProfileUseCase(this.repository);

  Future<OwnerEntity> call({
    String? name,
    String? surname,
    String? phone,
    String? address,
  }) async {
    return await repository.updateOwnerProfile(
      name: name,
      surname: surname,
      phone: phone,
      address: address,
    );
  }
}
