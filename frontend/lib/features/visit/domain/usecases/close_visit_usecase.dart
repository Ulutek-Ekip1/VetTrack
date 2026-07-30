import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';

class CloseVisitUseCase {
  final VisitRepository repository;

  CloseVisitUseCase(this.repository);

  Future<void> call(String visitId) async {
    await repository.closeVisit(visitId);
  }
}
