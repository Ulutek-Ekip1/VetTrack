package com.vettrack.api.visit;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping({"/visits", "/api/visits"})
@RequiredArgsConstructor
@Tag(name = "Ziyaret Yönetimi API", description = "Veteriner muayene ve ziyaret yönetimi uç noktaları")
public class VisitController {

    private final VisitService visitService;
    private final PetService petService;
    private final VetStaffService vetStaffService;
    private final OwnerService ownerService;

    private boolean isVetOrAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF") || a.getAuthority().equals("ROLE_ADMIN"));
    }

    private boolean isAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }

    private List<VisitResponse> toResponses(List<Visit> visits) {
        return visits.stream().map(VisitResponse::from).toList();
    }

    @PostMapping
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    @Operation(summary = "Yeni Muayene Ziyareti Başlat", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<VisitResponse> createVisit(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody VisitCreateRequest request
    ) {
        // visits.vet_staff_id -> profiles(id) FK'li ve check_visit_vet_staff_role() trigger'ı
        // bunun bir profiles satırına (JWT subject) ait olmasını doğruluyor — clinic_staff.id
        // (vetStaff.getId()) değil, vetStaff.getUserId() kullanılmalı.
        VetStaff vetStaff = vetStaffService.getOrCreateByUserId(UUID.fromString(jwt.getSubject()), jwt);
        Visit visit = visitService.createVisit(request.getPetId(), vetStaff.getUserId());
        return new ResponseEntity<>(VisitResponse.from(visit), HttpStatus.CREATED);
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<VisitResponse> closeVisit(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        Visit visit = visitService.getVisit(id);
        UUID currentUserId = UUID.fromString(jwt.getSubject());
        if (!isAdmin() && !currentUserId.equals(visit.getVetStaffId())) {
            throw new AccessDeniedException("Sadece ziyareti başlatan veteriner kapatabilir");
        }
        return ResponseEntity.ok(VisitResponse.from(visitService.closeVisit(id)));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<PatientSearchResponse> getPatientByCode(@PathVariable String code) {
        Pet pet = petService.getPetByUniqueCode(code);
        List<VisitResponse> visits = toResponses(visitService.getVisitsByUniqueCode(code));
        return ResponseEntity.ok(new PatientSearchResponse(pet, visits));
    }

    @GetMapping("/{visitId}/context")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ActiveVisitContextResponse> getActiveVisitContext(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID visitId
    ) {
        Visit visit = visitService.getVisit(visitId);
        Pet pet = petService.getPetById(visit.getPetId());

        UUID currentUserId = UUID.fromString(jwt.getSubject());

        if (!isVetOrAdmin() && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu ziyaret detayına erişim yetkiniz yok");
        }

        Owner owner = ownerService.getOwnerById(pet.getOwnerId());
        return ResponseEntity.ok(new ActiveVisitContextResponse(
                VisitResponse.from(visit), pet, owner, toResponses(visitService.getVisitsByPetId(pet.getId()))
        ));
    }

    @GetMapping({"/pet/{petId}", "/pets/{petId}/visits"})
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Pet'in Geçmiş Ziyaretlerini Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<VisitResponse>> getVisitsByPetId(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID petId
    ) {
        Pet pet = petService.getPetById(petId);
        UUID currentUserId = UUID.fromString(jwt.getSubject());

        if (!isVetOrAdmin() && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu pet'in ziyaret geçmişine erişim yetkiniz yok");
        }

        return ResponseEntity.ok(toResponses(visitService.getVisitsByPetId(petId)));
    }

    @GetMapping("/owner")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Sahibin ziyaret geçmişini listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<VisitResponse>> getOwnerVisitHistory(@AuthenticationPrincipal Jwt jwt) {
        if (isVetOrAdmin()) {
            throw new AccessDeniedException("Bu uç nokta yalnızca hayvan sahipleri içindir");
        }
        return ResponseEntity.ok(toResponses(visitService.getVisitsByOwnerId(UUID.fromString(jwt.getSubject()))));
    }

    @GetMapping("/vet")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    @Operation(summary = "Veterinerin ziyaret geçmişini listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<VisitResponse>> getVetVisitHistory(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(toResponses(visitService.getVisitsByVetStaffId(UUID.fromString(jwt.getSubject()))));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    @Operation(summary = "Ziyaret Durumunu Güncelle (ör. ongoing -> completed)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<VisitResponse> updateVisitStatus(
            @PathVariable UUID id,
            @RequestBody Map<String, String> statusMap
    ) {
        String newStatus = statusMap.getOrDefault("status", "completed");
        Visit updated = visitService.updateVisitStatus(id, newStatus);
        return ResponseEntity.ok(VisitResponse.from(updated));
    }
}
