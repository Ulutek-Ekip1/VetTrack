package com.vettrack.api.recommendation;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping({"", "/api"})
@RequiredArgsConstructor
@Tag(name = "Recommendation API", description = "Veteriner hekim tavsiye ve bakim onerileri API'leri")
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final com.vettrack.api.clinic.ClinicAccessService clinicAccessService;

    @PostMapping("/visits/{visitId}/recommendations")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Ziyarete Yeni Tavsiye/Bakim Onerisi Ekle", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<RecommendationResponse> createRecommendation(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID visitId,
            @Valid @RequestBody RecommendationCreateRequest request
    ) {
        UUID createdBy = jwt != null && jwt.getSubject() != null ? UUID.fromString(jwt.getSubject()) : null;
        clinicAccessService.requireVisitAccess(createdBy, visitId);
        RecommendationResponse created = recommendationService.createRecommendation(visitId, request, createdBy);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/pets/{id}/recommendations")
    @Operation(summary = "Pet'e Ait Tavsiyeleri Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<RecommendationResponse>> getRecommendationsByPet(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable("id") UUID petId
    ) {
        return ResponseEntity.ok(recommendationService.getRecommendationsByPetId(petId, jwt));
    }

    @GetMapping("/visits/{visitId}/recommendations")
    @Operation(summary = "Ziyarete Ait Tavsiyeleri Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<RecommendationResponse>> getRecommendationsByVisit(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable("visitId") UUID visitId
    ) {
        return ResponseEntity.ok(recommendationService.getRecommendationsByVisitId(visitId, jwt));
    }

}
