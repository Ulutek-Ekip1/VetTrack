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

        UUID clinicId = resolveClinicId(userId, request.getClinicId());
        membershipService.getActiveMembership(userId, clinicId);

        Visit visit = visitService.createVisit(request.getPetId(), userId, clinicId, request.getChiefComplaint());
        return new ResponseEntity<>(visit, HttpStatus.CREATED);
    }

    /**
     * clinicId istekte açıkça verilmemişse, kullanıcının tek bir aktif klinik üyeliği varsa
     * onu otomatik kullanır. Birden fazla aktif üyelikte açık clinicId zorunlu kalır, hiç
     * üyelik yoksa 401 döner.
     */
    private UUID resolveClinicId(UUID userId, UUID explicitClinicId) {
        if (explicitClinicId != null) {
            return explicitClinicId;
        }
        var memberships = membershipService.getMembershipsByUser(userId).stream()
                .filter(m -> "active".equals(m.getStatus())).toList();
        if (memberships.size() == 1) {
            return memberships.get(0).getClinicId();
        } else if (memberships.isEmpty()) {
            throw new com.vettrack.api.common.exception.UnauthorizedException("Aktif klinik uyeliginiz bulunmamaktadir.");
        } else {
            throw new IllegalArgumentException("Birden fazla klinikte aktifsiniz, lutfen clinicId belirtin.");
        }
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Visit> closeVisit(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        clinicAccessService.requireVisitAccess(UUID.fromString(jwt.getSubject()), id);
        return ResponseEntity.ok(visitService.closeVisit(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Takip Kodu ile Hasta Ara",
            description = "clinicId opsiyoneldir — verilmezse hekimin tek aktif klinik üyeliği "
                    + "otomatik kullanılır. Birden fazla aktif üyelikte clinicId zorunludur.",
            security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<PatientSearchResponse> getPatientByCode(@AuthenticationPrincipal Jwt jwt,
                                                                    @PathVariable String code,
                                                                    @RequestParam(required = false) UUID clinicId) {
        UUID userId = UUID.fromString(jwt.getSubject());
        UUID resolvedClinicId = resolveClinicId(userId, clinicId);
        clinicAccessService.requireClinicAccess(userId, resolvedClinicId);
        Pet pet = petService.getPetByUniqueCode(code);
        List<Visit> visits = visitService.getVisitsByPetIdAndClinicId(pet.getId(), resolvedClinicId);
        return ResponseEntity.ok(new PatientSearchResponse(pet, visits));
    }

    @GetMapping("/owner")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Sahibin Tüm Aktif Petlerinin Ziyaret Geçmişi",
            description = "Giriş yapmış hasta sahibinin sahip olduğu tüm aktif (silinmemiş) petlerin muayene "
                    + "geçmişini tek listede döner. Kayıt yoksa 200 OK + boş dizi.",
            security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Visit>> getVisitsForOwner(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(visitService.getVisitsForOwner(ownerId));
    }

    @GetMapping("/vet")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    @Operation(summary = "Hekime Atanmış Tüm Ziyaretler",
            description = "Giriş yapmış veteriner hekime atanmış tüm muayene/ziyaret kayıtlarını döner "
                    + "(silinmiş/pasif petlerinki hariç). Kayıt yoksa 200 OK + boş dizi.",
            security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Visit>> getVisitsForVet(@AuthenticationPrincipal Jwt jwt) {
        UUID vetStaffId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(visitService.getVisitsForVet(vetStaffId));
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

        List<Visit> allVisits;
        if (isVetOrAdmin()) {
            allVisits = visitService.getVisitsByPetId(pet.getId());
        } else {
            allVisits = visitService.getVisitsByPetId(pet.getId());
        }

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
        boolean isAdmin = auth != null && auth.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
        boolean isVet = auth != null && auth.getAuthorities().stream()
                .anyMatch(a -> "ROLE_VET_STAFF".equals(a.getAuthority()));

        if (isAdmin) {
            return ResponseEntity.ok(visitService.getVisitsByPetId(petId));
        }

        if (isVet) {
            // Vet sadece kendi aktif kliniklerine ait ziyaretleri görür — cross-clinic sızıntı önlenir.
            List<UUID> activeClinicIds = clinicAccessService.getActiveClinicIds(currentUserId);
            if (activeClinicIds.isEmpty()) {
                throw new AccessDeniedException("Bu pet'in ziyaret geçmişine erişim yetkiniz yok.");
            }
            return ResponseEntity.ok(visitService.getVisitsByPetIdAndClinicIds(petId, activeClinicIds));
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
