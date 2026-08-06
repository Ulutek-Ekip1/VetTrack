import 'package:equatable/equatable.dart';

class RecommendationEntity extends Equatable {
  final String id;
  final String visitId;
  final String type; // 'food', 'litter', 'other'
  final String description;
  final DateTime createdAt;

  const RecommendationEntity({
    required this.id,
    required this.visitId,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, visitId, type, description, createdAt];
}
