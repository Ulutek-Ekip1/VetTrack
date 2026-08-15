package com.vettrack.api.recommendation;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import com.vettrack.api.clinic.ClinicAccessService;
import com.vettrack.api.clinic.ClinicMembershipService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final RecommendationRepository recommendationRepository;
    private final VisitRepository visitRepository;
    private final PetRepository petRepository;
    private final ClinicAccessService clinicAccessService;
    private final ClinicMembershipService clinicMembershipService;

    @Transactional
    public RecommendationResponse createRecommendation(UUID visitId, RecommendationCreateRequest request, UUID createdBy) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadi ID: " + visitId));
        
        if ("CANCELLED".equalsIgnoreCase(visit.getStatus()) || "COMPLETED".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException(ErrorCode.VISIT_CLOSED, "Kapanmis veya iptal edilmis ziyarete oneri eklenemez.");
        }

        Recommendation rec = Recommendation.builder()
                .visitId(visitId)
                .type(request.getType())
                .description(request.getDescription())
                .createdBy(createdBy)
                .build();
        
        Recommendation savedRec = recommendationRepository.save(rec);
        return RecommendationMapper.toResponse(savedRec);
    }

    @Transactional(readOnly = true)
    public List<RecommendationResponse> getRecommendationsByPetId(UUID petId, Jwt jwt) {
        Pet pet = petRepository.findById(petId)
                .orElseThrow(() -> new ResourceNotFoundException("Pet bulunamadi ID: " + petId));

        if (jwt != null) {
            if (!isVetOrAdmin()) {
                UUID currentUserId = UUID.fromString(jwt.getSubject());
                if (!pet.getOwnerId().equals(currentUserId)) {
                    throw new AccessDeniedException("Sadece yetkililer veya pet sahibi bu tavsiyeleri gorebilir.");
                }
            }
        }

        List<Recommendation> recommendations = recommendationRepository.findByPetId(petId);
        return RecommendationMapper.toResponseList(recommendations);
    }

    @Transactional(readOnly = true)
    public List<RecommendationResponse> getRecommendationsByVisitId(UUID visitId, Jwt jwt) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadi ID: " + visitId));
        UUID userId = UUID.fromString(jwt.getSubject());
        if (clinicMembershipService.hasActiveMembership(userId)) {
            clinicAccessService.requireVisitAccess(userId, visitId);
        }
        return getRecommendationsByPetId(visit.getPetId(), jwt).stream()
                .filter(r -> r.getVisitId().equals(visitId))
                .toList();
    }


    private boolean isVetOrAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF") || 
                               a.getAuthority().equals("ROLE_CLINIC_ADMIN") || 
                               a.getAuthority().equals("ROLE_ADMIN"));
    }

}
