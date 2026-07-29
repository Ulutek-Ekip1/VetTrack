import 'package:equatable/equatable.dart';

enum UserRole {
  vet,
  owner
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, name, phone, role];
}
