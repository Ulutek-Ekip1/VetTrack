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
    super.birthDate,
    super.weight,
    super.microchipNo,
    super.isSpayedOrNeutered,
    super.bloodType,
    super.color,
    super.allergies,
    super.chronicIllnesses,
    super.weightHistory,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final genderString = json['gender'] as String?;
    Gender parsedGender = Gender.unknown; // Default

    if (genderString == 'male') {
      parsedGender = Gender.male;
    } else if (genderString == 'female') {
      parsedGender = Gender.female;
    }

    int? calculatedAge;
    if (json['birthDate'] != null) {
      calculatedAge = DateTime.now().year -
          DateTime.parse(json['birthDate'] as String).year;
    } else if (json['estimatedBirthYear'] != null) {
      calculatedAge = DateTime.now().year - (json['estimatedBirthYear'] as int);
    } else if (json['age'] != null) {
      calculatedAge = json['age'] as int?;
    }

    final String? species = json['species'] as String?;
    final String? breed = json['breed'] as String?;
    final String? combinedBreed = species != null && species.isNotEmpty
        ? (breed != null && breed.isNotEmpty ? "$species / $breed" : species)
        : breed;

    final birthDateStr = json['birthDate'] as String?;
    final DateTime? parsedBirthDate =
        birthDateStr != null ? DateTime.parse(birthDateStr) : null;

    double? parsedWeight;
    if (json['weight'] != null) {
      if (json['weight'] is num) {
        parsedWeight = (json['weight'] as num).toDouble();
      } else {
        parsedWeight = double.tryParse(json['weight'].toString());
      }
    }

    final bool? parsedSpayed =
        json['isSpayedOrNeutered'] as bool? ?? json['neutered'] as bool?;

    final List<dynamic>? weightHistoryJson =
        json['weightHistory'] as List<dynamic>?;
    final List<PetWeightModel>? parsedWeightHistory = weightHistoryJson
        ?.map((e) => PetWeightModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PetModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      age: calculatedAge,
      gender: parsedGender,
      breed: combinedBreed,
      uniqueCode: json['uniqueCode'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      birthDate: parsedBirthDate,
      weight: parsedWeight,
      microchipNo: json['microchipNo'] as String?,
      isSpayedOrNeutered: parsedSpayed,
      bloodType: json['bloodType'] as String?,
      color: json['color'] as String?,
      allergies: json['allergies'] as String?,
      chronicIllnesses: json['chronicIllnesses'] as String?,
      weightHistory: parsedWeightHistory,
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
      if (birthDate != null)
        'birthDate': birthDate!.toIso8601String().split('T')[0],
      if (weight != null) 'weight': weight,
      if (microchipNo != null) 'microchipNo': microchipNo,
      if (isSpayedOrNeutered != null) 'isSpayedOrNeutered': isSpayedOrNeutered,
      if (bloodType != null) 'bloodType': bloodType,
      if (color != null) 'color': color,
      if (allergies != null) 'allergies': allergies,
      if (chronicIllnesses != null) 'chronicIllnesses': chronicIllnesses,
      if (weightHistory != null)
        'weightHistory': weightHistory!.map((e) {
          if (e is PetWeightModel) return e.toJson();
          return {
            'date': e.date.toIso8601String().split('T')[0],
            'weight': e.weight,
          };
        }).toList(),
    };
  }
}

class PetWeightModel extends PetWeightEntity {
  const PetWeightModel({
    required super.date,
    required super.weight,
  });

  factory PetWeightModel.fromJson(Map<String, dynamic> json) {
    double parsedW = 0.0;
    if (json['weight'] != null) {
      if (json['weight'] is num) {
        parsedW = (json['weight'] as num).toDouble();
      } else {
        parsedW = double.tryParse(json['weight'].toString()) ?? 0.0;
      }
    }
    return PetWeightModel(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      weight: parsedW,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
    };
  }
}
