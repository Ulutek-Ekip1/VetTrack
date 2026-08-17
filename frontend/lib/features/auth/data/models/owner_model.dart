import '../../domain/entities/owner_entity.dart';

class OwnerModel extends OwnerEntity {
  const OwnerModel(
      {required super.id,
      required super.name,
      super.surname,
      required super.email,
      super.phone,
      super.address,
      required super.createdAt,
      super.profilePhotoUrl});

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    String nameVal = (json['name'] as String?) ?? "";
    String? surnameVal = json['surname'] as String?;

    if (nameVal.isEmpty) {
      final fullName = (json['fullName'] as String?) ?? "";
      if (fullName.isNotEmpty) {
        final parts = fullName.split(' ');
        if (parts.length > 1) {
          surnameVal = parts.last;
          nameVal = parts.sublist(0, parts.length - 1).join(' ');
        } else {
          nameVal = fullName;
        }
      }
    }

    if (nameVal.isEmpty) {
      nameVal = (json['email'] as String?)?.split('@').first ?? "Sahip";
    }

    DateTime createdAtVal;
    final createdAtStr =
        (json['createdAt'] as String?) ?? (json['created_at'] as String?);
    if (createdAtStr != null) {
      try {
        createdAtVal = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAtVal = DateTime.now();
      }
    } else {
      createdAtVal = DateTime.now();
    }

    final profilePhotoUrl = (json['profilePhotoUrl'] as String?);

    return OwnerModel(
        id: (json['id'] as String?) ?? "",
        name: nameVal,
        surname: surnameVal,
        email: (json['email'] as String?) ?? "",
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        createdAt: createdAtVal,
        profilePhotoUrl: profilePhotoUrl);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (surname != null) 'surname': surname,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'createdAt': createdAt.toIso8601String(),
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl
    };
  }
}
