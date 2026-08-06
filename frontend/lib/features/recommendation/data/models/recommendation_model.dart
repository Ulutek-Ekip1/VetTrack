import '../../domain/entities/recommendation_entity.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.id,
    required super.visitId,
    required super.type,
    required super.description,
    required super.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      visitId: json['visitId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitId': visitId,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
