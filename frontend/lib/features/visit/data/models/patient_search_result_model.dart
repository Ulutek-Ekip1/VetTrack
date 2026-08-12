import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';

class PatientSearchResultModel extends PatientSearchResult {
  const PatientSearchResultModel({required super.pet, required super.visits});

  factory PatientSearchResultModel.fromJson(Map<String, dynamic> json) {
    final visits = (json['visits'] as List<dynamic>? ?? const [])
        .map((visit) => VisitModel.fromJson(visit as Map<String, dynamic>))
        .toList();
    return PatientSearchResultModel(
      pet: PetModel.fromJson(json['pet'] as Map<String, dynamic>),
      visits: visits,
    );
  }
}
