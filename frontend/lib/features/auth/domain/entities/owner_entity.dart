import 'package:equatable/equatable.dart';

class OwnerEntity extends Equatable {
  final String id;
  final String name;
  final String? surname;
  final String email;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const OwnerEntity({
    required this.id,
    required this.name,
    this.surname,
    required this.email,
    this.phone,
    this.address,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, surname, email, phone, address, createdAt];
}
