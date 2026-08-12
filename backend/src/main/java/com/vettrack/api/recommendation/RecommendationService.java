package com.vettrack.api.recommendation;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RecommendationService {
    private final RecommendationRepository recommendationRepository;
    private final VisitRepository visitRepository;

    @Transactional
    public Recommendation create(UUID visitId, RecommendationCreateRequest request, UUID createdBy) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));
        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException("Kapalı ziyarete öneri eklenemez");
        }
        return recommendationRepository.save(Recommendation.builder()
                .visitId(visitId).type(request.getType()).description(request.getDescription())
                .createdBy(createdBy).build());
    }

    @Transactional(readOnly = true)
    public List<Recommendation> getByVisit(UUID visitId) {
        visitRepository.findById(visitId).orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));
        return recommendationRepository.findByVisitId(visitId);
    }
}
