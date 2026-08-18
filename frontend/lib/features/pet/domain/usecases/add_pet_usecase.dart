import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase(this.repository);
  Future<PetEntity> call({
    required String name,
    required Gender gender,
    int? age,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? microchipNo,
    bool? isSpayedOrNeutered,
    String? bloodType,
    String? color,
    String? allergies,
    String? chronicIllnesses,
  }) async {
    return await repository.addPet(
      name: name,
      gender: gender,
      age: age,
      breed: breed,
      birthDate: birthDate,
      weight: weight,
      microchipNo: microchipNo,
      isSpayedOrNeutered: isSpayedOrNeutered,
      bloodType: bloodType,
      color: color,
      allergies: allergies,
      chronicIllnesses: chronicIllnesses,
    );
  }
}
