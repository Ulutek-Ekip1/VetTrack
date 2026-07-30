import 'package:equatable/equatable.dart';
import '../../domain/entities/treatment_entity.dart';

abstract class TreatmentState extends Equatable {
  const TreatmentState();

  @override
  List<Object> get props => [];
}

//Ilk durum
class TreatmentInitial extends TreatmentState {}

//Yukleniyor durumu
class TreatmentLoading extends TreatmentState {}

//Basarili sekilde yuklendi
class TreatmentLoaded extends TreatmentState {
  final List<TreatmentEntity> treatments;

  const TreatmentLoaded(this.treatments);

  @override
  List<Object> get props => [treatments];
}

//Hata durumu
class TreatmentError extends TreatmentState {
  final String message;

  const TreatmentError(this.message);

  @override
  List<Object> get props => [message];
}

//Tedavi ekleme/guncelleme basarili
class TreatmentActionSuccess extends TreatmentState {
  final String message;

  const TreatmentActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

//Tedavi silme islemi devam ederken
class TreatmentDeleting extends TreatmentState {}

//Tedavi silme basarili
class TreatmentDeletedSuccess extends TreatmentState {
  final String message;

  const TreatmentDeletedSuccess(this.message);

  @override
  List<Object> get props => [message];
}
