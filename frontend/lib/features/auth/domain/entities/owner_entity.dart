import 'package:equatable/equatable.dart';

class OwnerEntity extends Equatable {
  final String id;
  final String name;
  final String? surname;
  final String email;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final String? profilePhotoUrl;

  const OwnerEntity(
      {required this.id,
      required this.name,
      this.surname,
      required this.email,
      this.phone,
      this.address,
      required this.createdAt,
      this.profilePhotoUrl});

  OwnerEntity copyWith({
    String? id,
    String? name,
    Object? surname = _sentinel,
    String? email,
    Object? phone = _sentinel,
    Object? address = _sentinel,
    DateTime? createdAt,
    Object? profilePhotoUrl = _sentinel,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname == _sentinel ? this.surname : surname as String?,
      email: email ?? this.email,
      phone: phone == _sentinel ? this.phone : phone as String?,
      address: address == _sentinel ? this.address : address as String?,
      createdAt: createdAt ?? this.createdAt,
      profilePhotoUrl: profilePhotoUrl == _sentinel
          ? this.profilePhotoUrl
          : profilePhotoUrl as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, surname, email, phone, address, createdAt, profilePhotoUrl];
}

const Object _sentinel = Object();
