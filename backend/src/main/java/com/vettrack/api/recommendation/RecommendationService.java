package com.vettrack.api.recommendation;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RecommendationRepository recommendationRepository;

    @Transactional
    public Recommendation create(UUID visitId, RecommendationCreateRequest request, UUID createdBy) {
        request.setVisitId(visitId);
        return createRecommendation(createdBy, request);
    }

    @Transactional
    public Recommendation createRecommendation(UUID createdBy, RecommendationCreateRequest request) {
        Recommendation rec = Recommendation.builder()
                .visitId(request.getVisitId())
                .type(request.getType())
                .description(request.getDescription())
                .createdBy(createdBy)
                .build();
        return recommendationRepository.save(rec);
    }

    @Transactional(readOnly = true)
    public List<Recommendation> getByVisit(UUID visitId) {
        return getRecommendationsByVisitId(visitId);
    }

    @Transactional(readOnly = true)
    public List<Recommendation> getRecommendationsByVisitId(UUID visitId) {
        return recommendationRepository.findByVisitId(visitId);
    }
}
