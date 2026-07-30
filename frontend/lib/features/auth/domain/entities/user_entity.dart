import 'package:equatable/equatable.dart';

enum UserRole {
  vet,
  owner
}

class UserEntity extends Equatable {
  final String id;
  final String authId;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.authId,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authId, email, name, phone, role, createdAt];
}
