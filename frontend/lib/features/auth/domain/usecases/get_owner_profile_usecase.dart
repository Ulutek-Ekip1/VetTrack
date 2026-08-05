import '../entities/owner_entity.dart';
import '../repositories/auth_repository.dart';

class GetOwnerProfileUseCase {
  final AuthRepository repository;

  GetOwnerProfileUseCase(this.repository);

  Future<OwnerEntity> call() async {
    return await repository.getOwnerProfile();
  }
}
