package com.vettrack.api.recommendation;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping({"", "/api"})
@RequiredArgsConstructor
@Tag(name = "Bakım ve Öneri API", description = "Veteriner hekim tavsiye ve bakım önerileri API'leri")
public class RecommendationController {

    private final RecommendationService recommendationService;

    @PostMapping({"/recommendations", "/visits/{visitId}/recommendations"})
    @Operation(summary = "Ziyarete Yeni Tavsiye/Bakım Önerisi Ekle", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Recommendation> createRecommendation(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable(required = false) UUID visitId,
            @Valid @RequestBody RecommendationCreateRequest request
    ) {
        UUID createdBy = jwt != null && jwt.getSubject() != null ? UUID.fromString(jwt.getSubject()) : null;
        if (visitId != null) {
            request.setVisitId(visitId);
        }
        Recommendation created = recommendationService.createRecommendation(createdBy, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping({"/visits/{visitId}/recommendations", "/recommendations/visit/{visitId}"})
    @Operation(summary = "Ziyarete Ait Tavsiyeleri Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Recommendation>> getRecommendationsByVisit(@PathVariable UUID visitId) {
        return ResponseEntity.ok(recommendationService.getRecommendationsByVisitId(visitId));
    }
}

