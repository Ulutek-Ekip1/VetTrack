package com.vettrack.api.visit;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/visits")
@RequiredArgsConstructor
public class VisitController {

    private final VisitService visitService;
    private final PetService petService;
    private final VetStaffService vetStaffService;
    private final OwnerService ownerService;

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> createVisit(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody VisitCreateRequest request
    ) {
        requireVetOrAdmin(jwt);
        VetStaff vetStaff = vetStaffService.getOrCreateByUserId(UUID.fromString(jwt.getSubject()), jwt);
        Visit visit = visitService.createVisit(request.getPetId(), vetStaff.getId());
        return new ResponseEntity<>(visit, HttpStatus.CREATED);
    }

    /**
     * JIT vet-staff provisioning must only run for a vetted role. The current
     * JWT setup does not yet map Supabase roles to Spring authorities, so this
     * explicit check protects the endpoint until method-security conversion is
     * introduced application-wide.
     */
    private void requireVetOrAdmin(Jwt jwt) {
        String role = resolveRole(jwt);
        if (!"vet_staff".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role)) {
            throw new AccessDeniedException("Bu işlem yalnızca veteriner personel tarafından yapılabilir");
        }
    }

    @SuppressWarnings("unchecked")
    private String resolveRole(Jwt jwt) {
        Object userMetadata = jwt.getClaim("user_metadata");
        if (userMetadata instanceof Map<?, ?> metadata) {
            Object role = metadata.get("role");
            if (role instanceof String roleValue && !roleValue.isBlank()) {
                return roleValue;
            }
        }

        String topLevelRole = jwt.getClaimAsString("role");
        return topLevelRole == null || topLevelRole.isBlank() ? "owner" : topLevelRole;
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> closeVisit(@PathVariable UUID id) {
        return ResponseEntity.ok(visitService.closeVisit(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PatientSearchResponse> getPatientByCode(@PathVariable String code) {
        Pet pet = petService.getPetByUniqueCode(code);
        List<Visit> visits = visitService.getVisitsByUniqueCode(code);
        return ResponseEntity.ok(new PatientSearchResponse(pet, visits));
    }

    @GetMapping("/{visitId}/context")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ActiveVisitContextResponse> getActiveVisitContext(@PathVariable UUID visitId) {
        Visit visit = visitService.getVisit(visitId);
        Pet pet = petService.getPetById(visit.getPetId());
        Owner owner = ownerService.getOwnerById(pet.getOwnerId());
        return ResponseEntity.ok(new ActiveVisitContextResponse(
                visit, pet, owner, visitService.getVisitsByPetId(pet.getId())
        ));
    }

    @GetMapping("/pet/{petId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Visit>> getVisitsByPetId(@PathVariable UUID petId) {
        return ResponseEntity.ok(visitService.getVisitsByPetId(petId));
    }
}
