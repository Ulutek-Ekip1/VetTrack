import 'package:equatable/equatable.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitSearchResult extends VisitState {
  final PatientSearchResult result;

  const VisitSearchResult(this.result);

  @override
  List<Object?> get props => [result.pet, result.visits];
}

class VisitStarted extends VisitState {
  final VisitEntity visit;

  const VisitStarted(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitHistoryLoaded extends VisitState {
  final List<VisitEntity> visits;

  const VisitHistoryLoaded(this.visits);

  @override
  List<Object?> get props => [visits];
}

class VisitClosed extends VisitState {}

class VisitError extends VisitState {
  final String message;

  const VisitError(this.message);

  @override
  List<Object?> get props => [message];
}
