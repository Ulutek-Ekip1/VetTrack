package com.vettrack.api.recommendation;

<<<<<<< HEAD
=======
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

<<<<<<< HEAD
import java.util.UUID;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class RecommendationController {
    private final RecommendationService recommendationService;

    @PostMapping("/visits/{visitId}/recommendations")
    public ResponseEntity<Recommendation> create(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID visitId,
                                                   @Valid @RequestBody RecommendationCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(recommendationService.create(visitId, request, UUID.fromString(jwt.getSubject())));
    }

    @GetMapping("/visits/{visitId}/recommendations")
    public ResponseEntity<List<Recommendation>> getByVisit(@PathVariable UUID visitId) {
        return ResponseEntity.ok(recommendationService.getByVisit(visitId));
=======
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping
@RequiredArgsConstructor
@Tag(name = "Bakım ve Öneri API", description = "Veteriner hekim tavsiye ve bakım önerileri API'leri")
public class RecommendationController {

    private final RecommendationService recommendationService;

    @PostMapping("/recommendations")
    @Operation(summary = "Ziyarete Yeni Tavsiye/Bakım Önerisi Ekle", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Recommendation> createRecommendation(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody RecommendationCreateRequest request
    ) {
        UUID createdBy = jwt != null && jwt.getSubject() != null ? UUID.fromString(jwt.getSubject()) : null;
        Recommendation created = recommendationService.createRecommendation(createdBy, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping({"/visits/{visitId}/recommendations", "/recommendations/visit/{visitId}"})
    @Operation(summary = "Ziyarete Ait Tavsiyeleri Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Recommendation>> getRecommendationsByVisit(@PathVariable UUID visitId) {
        return ResponseEntity.ok(recommendationService.getRecommendationsByVisitId(visitId));
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)
    }
}
