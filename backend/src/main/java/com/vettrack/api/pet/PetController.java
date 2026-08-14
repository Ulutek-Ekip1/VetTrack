package com.vettrack.api.pet;

import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/pets")
@RequiredArgsConstructor
@Tag(name = "Pet Yönetimi", description = "Evcil hayvan kayıt, güncelleme, listeleme, ziyaret geçmişi ve benzersiz kod ile arama API'leri")
public class PetController {

    private final PetService petService;
    private final VisitService visitService;
    private final com.vettrack.api.clinic.ClinicMembershipService clinicMembershipService;
    @PostMapping
    @Operation(summary = "Yeni Pet Ekle", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Pet başarıyla oluşturuldu"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim")
    })
    public ResponseEntity<Pet> createPet(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody PetCreateRequest request
    ) {
        Pet pet = Pet.builder()
                .ownerId(UUID.fromString(jwt.getSubject()))
                .name(request.getName())
                .species(request.getSpecies())
                .breed(request.getBreed())
                .gender(request.getGender())
                .birthDate(request.getBirthDate())
                .estimatedBirthYear(request.getEstimatedBirthYear())
                .photoUrl(request.getPhotoUrl())
                .build();

        Pet createdPet = petService.createPet(pet);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPet);
    }

    @GetMapping
    @Operation(summary = "Sahibin Petlerini Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<Pet>> getCurrentUserPets(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(petService.getPetsByOwner(ownerId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "ID ile Pet Getir", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet bilgisi getirildi"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<Pet> getPetById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        Pet pet = petService.getPetById(id);
        if (jwt != null) {
            UUID ownerId = UUID.fromString(jwt.getSubject());

            // If the caller is a vet staff (not admin), require an active clinic membership
            boolean isVetStaff = SecurityContextHolder.getContext().getAuthentication() != null &&
                    SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                            .anyMatch(a -> "ROLE_VET_STAFF".equals(a.getAuthority()));

            if (isVetStaff) {
                if (!clinicMembershipService.hasActiveMembership(ownerId)) {
                    throw new AccessDeniedException("Aktif bir klinik üyeliğiniz yok.");
                }
                // vets with active membership can view pet details
                return ResponseEntity.ok(pet);
            }

            // existing behavior for owners and admins
            boolean isStaffOrAdmin = isVetOrAdmin();
            if (!isStaffOrAdmin && !pet.getOwnerId().equals(ownerId)) {
                throw new AccessDeniedException("Bu hayvan size ait değil");
            }
        }
        return ResponseEntity.ok(pet);
    }

    @GetMapping("/{id}/visits")
    @Operation(summary = "Pet'in Ziyaret Geçmişini Sayfalamalı Listele", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Sayfalandırılmış ziyaret geçmişi başarıyla getirildi"),
        @ApiResponse(responseCode = "403", description = "Bu hayvanın ziyaret geçmişine erişim yetkiniz yok"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<Page<Visit>> getPetVisitsPaginated(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @ParameterObject Pageable pageable
    ) {
        Pet pet = petService.getPetById(id);
        UUID ownerId = UUID.fromString(jwt.getSubject());
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new AccessDeniedException("Bu hayvanın ziyaret geçmişini görüntüleme yetkiniz yoktur");
        }
        return ResponseEntity.ok(visitService.getVisitsByPetIdPaginated(id, pageable));
    }

    @GetMapping("/code/{uniqueCode}")
    @Operation(summary = "Benzersiz Kod ile Pet Bul", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Pet> getPetByUniqueCode(@PathVariable String uniqueCode) {
        return ResponseEntity.ok(petService.getPetByUniqueCode(uniqueCode));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Pet Bilgilerini Güncelle", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet güncellendi"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<Pet> updatePet(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody PetUpdateRequest request
    ) {
        Pet pet = petService.getPetById(id);
        if (jwt != null) {
            UUID ownerId = UUID.fromString(jwt.getSubject());
            if (!pet.getOwnerId().equals(ownerId)) {
                throw new AccessDeniedException("Bu hayvan size ait değil");
            }
        }
        return ResponseEntity.ok(petService.updatePet(id, request));
    }

    @PostMapping(value = "/{id}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Pet Fotoğrafı Yükle", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Map<String, String>> uploadPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file
    ) {
        Pet pet = petService.getPetById(id);
        UUID ownerId = UUID.fromString(jwt.getSubject());
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new AccessDeniedException("Bu hayvan size ait değil");
        }
        String photoUrl = petService.uploadPhoto(id, file);
        return ResponseEntity.ok(Map.of("photoUrl", photoUrl));
    }

    @DeleteMapping("/{id}/photo")
    @Operation(summary = "Pet Fotoğrafını Sil", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Fotoğraf silindi (fotoğraf zaten yoksa da 204 döner)"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<Void> deletePhoto(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        petService.deletePetPhoto(id, ownerId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Pet Sil (Soft Delete)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> deletePet(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        petService.softDeletePet(id, ownerId);
        return ResponseEntity.noContent().build();
    }

    private boolean isVetOrAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getAuthorities() == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> {
            String authority = a.getAuthority();
            return "ROLE_VET_STAFF".equals(authority) || "ROLE_ADMIN".equals(authority) || "ROLE_VET".equals(authority);
        });
    }
}
