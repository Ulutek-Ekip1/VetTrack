enum UserRole { owner, vet }

class AuthEntity {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const AuthEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}
