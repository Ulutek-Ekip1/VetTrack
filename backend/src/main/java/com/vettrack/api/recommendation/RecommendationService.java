package com.vettrack.api.recommendation;

<<<<<<< HEAD
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
=======
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

<<<<<<< HEAD
import java.util.UUID;
import java.util.List;
=======
import java.util.List;
import java.util.UUID;
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)

@Service
@RequiredArgsConstructor
public class RecommendationService {
<<<<<<< HEAD
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
=======

    private final RecommendationRepository recommendationRepository;

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
    public List<Recommendation> getRecommendationsByVisitId(UUID visitId) {
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)
        return recommendationRepository.findByVisitId(visitId);
    }
}
