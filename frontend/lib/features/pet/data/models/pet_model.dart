// Pet Model
class PetModel {
  String name;
  String photoUrl;
  String? breed;

  PetModel({
    required this.name,
    required this.photoUrl,
    this.breed,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      name: json['name'],
      photoUrl: json['photoUrl'],
      breed: json['breed'],
    );
  }

  toJson() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'breed': breed,
    };
  }
}
