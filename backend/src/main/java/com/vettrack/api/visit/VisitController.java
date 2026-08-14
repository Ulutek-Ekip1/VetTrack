package com.vettrack.api.visit;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;

import com.vettrack.api.clinic.ClinicMembershipService;
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
    private final ClinicMembershipService membershipService;
    private final com.vettrack.api.clinic.ClinicAccessService clinicAccessService;
    private final OwnerService ownerService;

    private boolean isVetOrAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF") || a.getAuthority().equals("ROLE_ADMIN"));
    }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Yeni Muayene Ziyareti Başlat", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Visit> createVisit(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody VisitCreateRequest request
    ) {
        // visits.vet_staff_id -> profiles(id) FK'li ve check_visit_vet_staff_role() trigger'ı
        // bunun bir profiles satırına (JWT subject) ait olmasını doğruluyor — clinic_staff.id
        // (vetStaff.getId()) değil, vetStaff.getUserId() kullanılmalı.

                UUID userId = UUID.fromString(jwt.getSubject());

        UUID clinicId = null;
        if (request.getClinicId() != null) {
            clinicId = request.getClinicId();
        } else {
            var memberships = membershipService.getMembershipsByUser(userId).stream().filter(m -> "active".equals(m.getStatus())).toList();
            if (memberships.size() == 1) {
                clinicId = memberships.get(0).getClinicId();
            } else if (memberships.isEmpty()) {
                throw new com.vettrack.api.common.exception.UnauthorizedException("Aktif klinik uyeliginiz bulunmamaktadir.");
            } else {
                throw new IllegalArgumentException("Birden fazla klinikte aktifsiniz, lutfen clinicId belirtin.");
            }
        }

        membershipService.getActiveMembership(userId, clinicId);

        Visit visit = visitService.createVisit(request.getPetId(), userId, clinicId, request.getChiefComplaint());
        return new ResponseEntity<>(visit, HttpStatus.CREATED);
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> closeVisit(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        clinicAccessService.requireVisitAccess(UUID.fromString(jwt.getSubject()), id);
        return ResponseEntity.ok(visitService.closeVisit(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PatientSearchResponse> getPatientByCode(@AuthenticationPrincipal Jwt jwt,
                                                                    @PathVariable String code,
                                                                    @RequestParam UUID clinicId) {
        clinicAccessService.requireClinicAccess(UUID.fromString(jwt.getSubject()), clinicId);
        Pet pet = petService.getPetByUniqueCode(code);
        List<Visit> visits = visitService.getVisitsByPetIdAndClinicId(pet.getId(), clinicId);
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

        if (!pet.getOwnerId().equals(currentUserId)) {
            clinicAccessService.requireVisitAccess(currentUserId, visitId);
        } else if (!isVetOrAdmin() && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu ziyaret detayına erişim yetkiniz yok");
        }

        Owner owner = ownerService.getOwnerById(pet.getOwnerId());

        // Tüm vet_staff tüm kliniklerin ziyaret geçmişini okuyabilir (ürün kuralı).
        // Klinik filtresi yalnızca yazma işlemlerinde (createVisit, closeVisit vb.) uygulanır.
        List<Visit> allVisits = visitService.getVisitsByPetId(pet.getId());

        return ResponseEntity.ok(new ActiveVisitContextResponse(
                visit, pet, owner, allVisits
        ));
    }

    @GetMapping({"/pet/{petId}", "/pets/{petId}/visits"})
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Pet'in Geçmiş Ziyaretlerini Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Visit>> getVisitsByPetId(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID petId
    ) {
        Pet pet = petService.getPetById(petId);
        UUID currentUserId = UUID.fromString(jwt.getSubject());

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isVetOrAdmin = auth != null && auth.getAuthorities().stream()
                .anyMatch(a -> "ROLE_VET_STAFF".equals(a.getAuthority()) || "ROLE_ADMIN".equals(a.getAuthority()));

        // Tüm vet_staff/admin tüm kliniklerin ziyaret geçmişini okuyabilir (ürün kuralı).
        if (isVetOrAdmin) {
            return ResponseEntity.ok(visitService.getVisitsByPetId(petId));
        }

        if (!pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu pet'in ziyaret geçmişine erişim yetkiniz yok.");
        }

        return ResponseEntity.ok(visitService.getVisitsByPetId(petId));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Ziyaret Durumunu Güncelle (ör. ongoing -> completed)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Visit> updateVisitStatus(@AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @RequestBody Map<String, String> statusMap
    ) {
        clinicAccessService.requireVisitAccess(UUID.fromString(jwt.getSubject()), id);
        String newStatus = statusMap.getOrDefault("status", "completed");
        Visit updated = visitService.updateVisitStatus(id, newStatus);
        return ResponseEntity.ok(updated);
    }
}
