// Pet Model

import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.ownerId,
    required super.name,
    super.age,
    required super.gender,
    super.breed,
    required super.uniqueCode,
    super.photoUrl,
    required super.createdAt,
    super.deletedAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final genderString = json['gender'] as String?;
    Gender parsedGender = Gender.unknown; // Default

    if (genderString == 'male') {
      parsedGender = Gender.male;
    } else if (genderString == 'female') {
      parsedGender = Gender.female;
    }

    return PetModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      gender: parsedGender,
      breed: json['breed'] as String?,
      uniqueCode: json['uniqueCode'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      if (age != null) 'age': age,
      'gender': gender.name,
      if (breed != null) 'breed': breed,
      'uniqueCode': uniqueCode,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
    };
  }
}
