package com.vettrack.api.treatment;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@Tag(name = "Tedavi Yönetimi", description = "Tedavi girişi ekleme, listeleme, düzenleme ve silme API'leri")
public class TreatmentController {

    private final TreatmentService treatmentService;
    private final VisitService visitService;
    private final PetService petService;

    private boolean isVetOrAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF") || a.getAuthority().equals("ROLE_ADMIN"));
    }

    @PostMapping("/visits/{visitId}/treatments")
    @Operation(
        summary = "Tedavi Girişi Ekle",
        description = "Ziyarete yeni tedavi kaydı ekler (FR-07). Ziyaret ongoing olmalıdır.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Tedavi kaydı başarıyla oluşturuldu"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek parametreleri"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "403", description = "Yetkiniz yok"),
        @ApiResponse(responseCode = "404", description = "Ziyaret bulunamadı"),
        @ApiResponse(responseCode = "409", description = "Ziyaret kapalı (VISIT_CLOSED)")
    })
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<TreatmentEntry> createTreatment(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Ziyaret UUID") @PathVariable UUID visitId,
            @Valid @RequestBody TreatmentCreateRequest request
    ) {
        UUID vetStaffId = UUID.fromString(jwt.getSubject());
        TreatmentEntry entry = treatmentService.createTreatment(visitId, request, vetStaffId);
        return ResponseEntity.status(HttpStatus.CREATED).body(entry);
    }

    @GetMapping("/visits/{visitId}/treatments")
    @Operation(
        summary = "Ziyaretin Tedavilerini Listele",
        description = "Ziyaretin tüm tedavilerini startDate DESC sıralı getirir. "
                    + "Opsiyonel ?status= filtresi destekler (FR-07).",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Tedavi listesi başarıyla getirildi"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Ziyaret bulunamadı")
    })
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<TreatmentEntry>> getTreatments(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Ziyaret UUID") @PathVariable UUID visitId,
            @Parameter(description = "Durum filtresi: PLANNED, IN_PROGRESS, COMPLETED, CANCELLED")
            @RequestParam(required = false) TreatmentStatus status
    ) {
        Visit visit = visitService.getVisit(visitId);
        Pet pet = petService.getPetById(visit.getPetId());

        UUID currentUserId = UUID.fromString(jwt.getSubject());

        if (!isVetOrAdmin() && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu ziyaretin tedavi geçmişine erişim yetkiniz yok");
        }

        return ResponseEntity.ok(treatmentService.getTreatmentsByVisit(visitId, status));
    }

    @GetMapping("/pets/{petId}/treatments")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<TreatmentEntry>> getPetTreatments(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID petId
    ) {
        Pet pet = petService.getPetById(petId);
        UUID currentUserId = UUID.fromString(jwt.getSubject());

        if (!isVetOrAdmin() && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu pet'in tedavi geçmişine erişim yetkiniz yok");
        }

        return ResponseEntity.ok(treatmentService.getTreatmentsByPet(petId));
    }

    @PutMapping("/treatments/{id}")
    @Operation(
        summary = "Tedavi Düzenle (15 dk pencere)",
        description = "Tedavi kaydını günceller. Sadece kaydı giren vet_staff, 15 dakika içinde (EC-08).",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Tedavi başarıyla güncellendi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek parametreleri"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "403", description = "Düzenleme süresi doldu (EDIT_WINDOW_EXPIRED) veya başkasının kaydı"),
        @ApiResponse(responseCode = "404", description = "Tedavi kaydı bulunamadı")
    })
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<TreatmentEntry> updateTreatment(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Tedavi UUID") @PathVariable UUID id,
            @RequestBody TreatmentUpdateRequest request
    ) {
        UUID vetStaffId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(treatmentService.updateTreatment(id, request, vetStaffId));
    }

    @DeleteMapping("/treatments/{id}")
    @Operation(
        summary = "Tedavi Sil (15 dk pencere)",
        description = "Tedavi kaydını siler. Sadece kaydı giren vet_staff, 15 dakika içinde (EC-08). Hard delete.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Tedavi başarıyla silindi"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "403", description = "Düzenleme süresi doldu (EDIT_WINDOW_EXPIRED) veya başkasının kaydı"),
        @ApiResponse(responseCode = "404", description = "Tedavi kaydı bulunamadı")
    })
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<Void> deleteTreatment(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Tedavi UUID") @PathVariable UUID id
    ) {
        UUID vetStaffId = UUID.fromString(jwt.getSubject());
        treatmentService.deleteTreatment(id, vetStaffId);
        return ResponseEntity.noContent().build();
    }
}
