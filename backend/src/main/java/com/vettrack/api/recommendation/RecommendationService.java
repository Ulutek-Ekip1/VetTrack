package com.vettrack.api.recommendation;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RecommendationRepository recommendationRepository;
    private final VisitRepository visitRepository;

    @Transactional
    public Recommendation create(UUID visitId, RecommendationCreateRequest request, UUID createdBy) {
        request.setVisitId(visitId);
        return createRecommendation(createdBy, request);
    }

    @Transactional
    public Recommendation createRecommendation(UUID createdBy, RecommendationCreateRequest request) {
        if (request.getVisitId() == null) {
            throw new IllegalArgumentException("Ziyaret (visitId) zorunludur.");
        }
        Visit visit = visitRepository.findById(request.getVisitId())
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı ID: " + request.getVisitId()));
        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException(ErrorCode.VISIT_CLOSED, "Kapalı veya tamamlanmış ziyarete öneri eklenemez.");
        }

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
