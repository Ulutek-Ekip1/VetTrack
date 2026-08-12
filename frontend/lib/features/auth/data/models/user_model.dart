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
    // Supabase top-level `role` is usually `authenticated`; the application
    // role is stored in user_metadata.role and must take precedence.
    final metadataRole = json['user_metadata'] is Map
        ? (json['user_metadata'] as Map)['role'] as String?
        : null;
    final rawRole = metadataRole ?? json['role'] as String?;
    UserRole parsedRole = UserRole.owner; // Default

    if (rawRole == 'vet_staff' || rawRole == 'VET') {
      parsedRole = UserRole.vet;
    }

    // Name parsing (supporting top-level name and nested user_metadata name/full_name)
    String name = (json['name'] as String?) ?? "";
    if (name.isEmpty && json['user_metadata'] is Map) {
      final meta = json['user_metadata'] as Map;
      name = (meta['name'] as String?) ?? (meta['full_name'] as String?) ?? "";
    }
    if (name.isEmpty) {
      name = (json['email'] as String?)?.split('@').first ?? "Kullanıcı";
    }

    // Phone parsing
    String? phone = json['phone'] as String?;
    if ((phone == null || phone.isEmpty) && json['user_metadata'] is Map) {
      final meta = json['user_metadata'] as Map;
      phone = meta['phone'] as String?;
    }

    // CreatedAt parsing
    DateTime createdAtVal;
    final createdAtStr = (json['createdAt'] as String?) ?? (json['created_at'] as String?);
    if (createdAtStr != null) {
      try {
        createdAtVal = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAtVal = DateTime.now();
      }
    } else {
      createdAtVal = DateTime.now();
    }

    final idVal = (json['id'] as String?) ?? "";

    return UserModel(
      id: idVal,
      authId: (json['authId'] as String?) ?? idVal,
      email: (json['email'] as String?) ?? "",
      name: name,
      phone: phone,
      role: parsedRole,
      createdAt: createdAtVal,
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
