import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/active_visit_context.dart';

class ActiveVisitContextModel extends ActiveVisitContext {
  const ActiveVisitContextModel({required super.visit, required super.pet, required super.ownerName, super.ownerPhone, required super.history});
  factory ActiveVisitContextModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>;
    return ActiveVisitContextModel(
      visit: VisitModel.fromJson(json['visit'] as Map<String, dynamic>),
      pet: PetModel.fromJson(json['pet'] as Map<String, dynamic>),
      ownerName: (owner['fullName'] ?? owner['full_name'] ?? 'Bilinmiyor').toString(),
      ownerPhone: (owner['phone'] as String?),
      history: (json['history'] as List<dynamic>? ?? const []).map((v) => VisitModel.fromJson(v as Map<String, dynamic>)).toList(),
    );
  }
}
