package com.vettrack.api.recommendation;

import com.vettrack.api.auth.AccessControlService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class RecommendationController {
    private final RecommendationService recommendationService;
    private final AccessControlService accessControlService;

    @PostMapping("/visits/{visitId}/recommendations")
    public ResponseEntity<Recommendation> create(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID visitId,
                                                   @Valid @RequestBody RecommendationCreateRequest request) {
        accessControlService.requireVetOrAdmin(jwt);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(recommendationService.create(visitId, request, UUID.fromString(jwt.getSubject())));
    }

    @GetMapping("/visits/{visitId}/recommendations")
    public ResponseEntity<List<Recommendation>> getByVisit(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID visitId
    ) {
        accessControlService.requireVetOrOwnerOfVisit(jwt, visitId);
        return ResponseEntity.ok(recommendationService.getByVisit(visitId));
    }
}
