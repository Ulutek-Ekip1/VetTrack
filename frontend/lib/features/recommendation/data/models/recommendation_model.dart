import '../../domain/entities/recommendation_entity.dart';

// API'den gelen JSON verisini Dart nesnesine dönüştürmek için
class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.id,
    required super.visitId,
    required super.type,
    required super.description,
    required super.createdAt,
  });

//JSON -> Model dönüşümü
  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'].toString(),
      visitId: (json['visitId'] ?? json['visit_id']).toString(),
      type: json['type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
    );
  }

//Model -> JSON dönüşümü
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
