package com.vettrack.api.recommendation;

import java.util.List;
import java.util.stream.Collectors;

public class RecommendationMapper {

    private RecommendationMapper() {
        // Utility class
    }

    public static RecommendationResponse toResponse(Recommendation recommendation) {
        if (recommendation == null) {
            return null;
        }

        return RecommendationResponse.builder()
                .id(recommendation.getId())
                .visitId(recommendation.getVisitId())
                .type(recommendation.getType())
                .description(recommendation.getDescription())
                .createdBy(recommendation.getCreatedBy())
                .createdAt(recommendation.getCreatedAt())
                .updatedAt(recommendation.getUpdatedAt())
                .build();
    }

    public static List<RecommendationResponse> toResponseList(List<Recommendation> recommendations) {
        if (recommendations == null) {
            return null;
        }
        return recommendations.stream()
                .map(RecommendationMapper::toResponse)
                .collect(Collectors.toList());
    }
}