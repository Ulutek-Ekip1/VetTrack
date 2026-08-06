import '../../domain/entities/owner_entity.dart';

class OwnerModel extends OwnerEntity {
  const OwnerModel({
    required super.id,
    required super.name,
    super.surname,
    required super.email,
    super.phone,
    super.address,
    required super.createdAt,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
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
    };
  }
}
