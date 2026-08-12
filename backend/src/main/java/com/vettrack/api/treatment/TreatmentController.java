package com.vettrack.api.treatment;

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
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@Tag(name = "Tedavi Yönetimi", description = "Tedavi girişi ekleme, listeleme, düzenleme ve silme API'leri")
public class TreatmentController {

    private final TreatmentService treatmentService;

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
        @ApiResponse(responseCode = "404", description = "Ziyaret bulunamadı"),
        @ApiResponse(responseCode = "409", description = "Ziyaret kapalı (VISIT_CLOSED)")
    })
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
        @ApiResponse(responseCode = "404", description = "Ziyaret bulunamadı")
    })
    public ResponseEntity<List<TreatmentEntry>> getTreatments(
            @Parameter(description = "Ziyaret UUID") @PathVariable UUID visitId,
            @Parameter(description = "Durum filtresi: PLANNED, IN_PROGRESS, COMPLETED, CANCELLED")
            @RequestParam(required = false) TreatmentStatus status
    ) {
        return ResponseEntity.ok(treatmentService.getTreatmentsByVisit(visitId, status));
    }

    @GetMapping("/pets/{petId}/treatments")
    public ResponseEntity<List<TreatmentEntry>> getPetTreatments(@PathVariable UUID petId) {
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
    public ResponseEntity<Void> deleteTreatment(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Tedavi UUID") @PathVariable UUID id
    ) {
        UUID vetStaffId = UUID.fromString(jwt.getSubject());
        treatmentService.deleteTreatment(id, vetStaffId);
        return ResponseEntity.noContent().build();
    }
}
