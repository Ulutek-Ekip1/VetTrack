import 'package:equatable/equatable.dart';
import 'package:vettrack_frontend/features/pet/data/models/pet_model.dart';

abstract class PetState extends Equatable {
  const PetState();
  @override
  List<Object> get props => [];
}

// 1. Durum: Sayfa ilk açıldığında veya hiçbir şey yapılmadığında
class PetInitial extends PetState {}

// 2. Durum: Veri yükleniyor (Ekranda dönen loading çubuğu göstereceğiz)
class PetLoading extends PetState {}

// 3. Durum: Veri başarıyla geldi (Ekranda listeyi çizeceğiz)
class PetLoaded extends PetState {
  final List<PetModel> pets;

  const PetLoaded({required this.pets});

  @override
  List<Object> get props => [pets];
}

// 4. Durum: Bir hata oldu (Ekranda kırmızı bir uyarı göstereceğiz)
class PetError extends PetState {
  final String message;

  const PetError({required this.message});

  @override
  List<Object> get props => [message];
}
