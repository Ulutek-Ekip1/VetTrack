import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.authId,
    required super.email,
    required super.name,
    super.phone,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String?;
    UserRole parsedRole = UserRole.owner; // Default

    if (rawRole == 'vet_staff' || rawRole == 'VET') {
      parsedRole = UserRole.vet;
    }

    return UserModel(
      id: json['id'] as String,
      authId: json['authId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: parsedRole,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authId': authId,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      'role': role == UserRole.vet ? 'vet_staff' : 'owner',
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
