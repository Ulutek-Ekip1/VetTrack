import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';

class SearchByCodeUseCase {
  final VisitRepository repository;

  SearchByCodeUseCase(this.repository);

  Future<PatientSearchResult> call(String code) async {
    return await repository.searchByCode(code);
  }
}
