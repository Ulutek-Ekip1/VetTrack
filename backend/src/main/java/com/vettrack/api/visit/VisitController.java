package com.vettrack.api.visit;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.auth.AccessControlService;
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
@RequestMapping("/visits")
@RequiredArgsConstructor
public class VisitController {

    private final VisitService visitService;
    private final PetService petService;
    private final VetStaffService vetStaffService;
    private final OwnerService ownerService;
    private final AccessControlService accessControlService;

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> createVisit(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody VisitCreateRequest request
    ) {
        accessControlService.requireVetOrAdmin(jwt);
        VetStaff vetStaff = vetStaffService.getOrCreateByUserId(UUID.fromString(jwt.getSubject()), jwt);
        Visit visit = visitService.createVisit(request.getPetId(), vetStaff.getId());
        return new ResponseEntity<>(visit, HttpStatus.CREATED);
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> closeVisit(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        accessControlService.requireVetOrAdmin(jwt);
        return ResponseEntity.ok(visitService.closeVisit(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PatientSearchResponse> getPatientByCode(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String code
    ) {
        accessControlService.requireVetOrAdmin(jwt);
        Pet pet = petService.getPetByUniqueCode(code);
        List<Visit> visits = visitService.getVisitsByUniqueCode(code);
        return ResponseEntity.ok(new PatientSearchResponse(pet, visits));
    }

    @GetMapping("/{visitId}/context")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ActiveVisitContextResponse> getActiveVisitContext(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID visitId
    ) {
        accessControlService.requireVetOrAdmin(jwt);
        Visit visit = visitService.getVisit(visitId);
        Pet pet = petService.getPetById(visit.getPetId());
        Owner owner = ownerService.getOwnerById(pet.getOwnerId());
        return ResponseEntity.ok(new ActiveVisitContextResponse(
                visit, pet, owner, visitService.getVisitsByPetId(pet.getId())
        ));
    }

    @GetMapping("/pet/{petId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Visit>> getVisitsByPetId(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID petId
    ) {
        accessControlService.requireVetOrAdmin(jwt);
        return ResponseEntity.ok(visitService.getVisitsByPetId(petId));
    }
}
