// Pet Entity
import 'package:equatable/equatable.dart';

enum Gender { male, female, unknown }

class PetEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final int? age;
  final Gender gender;
  final String? breed;
  final String uniqueCode;
  final String? photoUrl;
  final DateTime createdAt;

  const PetEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    this.age,
    required this.gender,
    this.breed,
    required this.uniqueCode,
    this.photoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        age,
        gender,
        breed,
        uniqueCode,
        photoUrl,
        createdAt,
      ];
}
