package com.vettrack.api.pet;

import com.vettrack.api.pet.dto.PetHealthHistoryResponse;
import com.vettrack.api.pet.dto.PetResponse;
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

    @PostMapping
    @Operation(summary = "Yeni Pet Ekle", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Pet başarıyla oluşturuldu"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim")
    })
    public ResponseEntity<PetResponse> createPet(
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
                .weight(request.getWeight())
                .microchipNo(request.getMicrochipNo())
                .isSpayedOrNeutered(request.getIsSpayedOrNeutered())
                .bloodType(request.getBloodType())
                .color(request.getColor())
                .allergies(request.getAllergies())
                .chronicIllnesses(request.getChronicIllnesses())
                .build();

        Pet createdPet = petService.createPet(pet);
        return ResponseEntity.status(HttpStatus.CREATED).body(PetResponse.fromEntity(createdPet));
    }

    @GetMapping
    @Operation(summary = "Sahibin Petlerini Listele", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<PetResponse>> getCurrentUserPets(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        List<PetResponse> pets = petService.getPetsByOwner(ownerId).stream()
                .map(PetResponse::fromEntity)
                .toList();
        return ResponseEntity.ok(pets);
    }

    @GetMapping("/{id}")
    @Operation(summary = "ID ile Pet Getir", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet bilgisi getirildi"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<PetResponse> getPetById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        Pet pet = petService.getPetById(id);
        UUID currentUserId = UUID.fromString(jwt.getSubject());

        boolean isAdmin = isRole("ROLE_ADMIN");
        boolean isVetStaff = isRole("ROLE_VET_STAFF");

        if (isAdmin) {
            return ResponseEntity.ok(PetResponse.fromEntity(pet));
        }
        if (isVetStaff) {
            return ResponseEntity.ok(PetResponse.fromEntity(pet));
        }

        if (!pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu hayvan size ait değil");
        }
        return ResponseEntity.ok(PetResponse.fromEntity(pet));
    }

    @GetMapping("/{id}/health-history")
    @Operation(summary = "Pet Sağlık Geçmişi ve Klinik Detaylarını Getir", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Sağlık geçmişi başarıyla getirildi"),
        @ApiResponse(responseCode = "403", description = "Bu hayvanın sağlık geçmişine erişim yetkiniz yok"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<PetHealthHistoryResponse> getPetHealthHistory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        Pet pet = petService.getPetById(id);
        UUID currentUserId = UUID.fromString(jwt.getSubject());

        boolean isAdmin = isRole("ROLE_ADMIN");
        boolean isVetStaff = isRole("ROLE_VET_STAFF");

        if (!isAdmin && !isVetStaff && !pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu hayvanın sağlık geçmişini görüntüleme yetkiniz yoktur");
        }

        return ResponseEntity.ok(petService.getPetHealthHistory(id));
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
        UUID currentUserId = UUID.fromString(jwt.getSubject());
        boolean isAdmin = isRole("ROLE_ADMIN");
        boolean isVetStaff = isRole("ROLE_VET_STAFF");

        if (isAdmin) {
            return ResponseEntity.ok(visitService.getVisitsByPetIdPaginated(id, pageable));
        }
        if (isVetStaff) {
            return ResponseEntity.ok(visitService.getVisitsByPetIdPaginated(id, pageable));
        }
        if (!pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu hayvanın ziyaret geçmişini görüntüleme yetkiniz yoktur");
        }
        return ResponseEntity.ok(visitService.getVisitsByPetIdPaginated(id, pageable));
    }

    @GetMapping("/{id}/weight-history")
    @Operation(summary = "Pet'in Kilo Geçmişini Listele (Seçenek A)", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Kilo geçmişi başarıyla getirildi"),
        @ApiResponse(responseCode = "403", description = "Bu hayvanın kilo geçmişine erişim yetkiniz yok"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<?> getPetWeightHistory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @ParameterObject Pageable pageable
    ) {
        Pet pet = petService.getPetById(id);
        UUID currentUserId = UUID.fromString(jwt.getSubject());
        boolean isAdmin = isRole("ROLE_ADMIN");
        boolean isVetStaff = isRole("ROLE_VET_STAFF");

        if (isAdmin) {
            // Admin tüm verileri görebilir
        } else if (isVetStaff) {
            // Vet staff tüm petlerin kilo geçmişini görebilir
        } else if (!pet.getOwnerId().equals(currentUserId)) {
            throw new AccessDeniedException("Bu hayvanın kilo geçmişini görüntüleme yetkiniz yoktur");
        }

        if (page != null || size != null) {
            return ResponseEntity.ok(petService.getWeightHistoryPaginated(id, pageable));
        }
        return ResponseEntity.ok(petService.getWeightHistory(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Pet Bilgilerini Güncelle", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet güncellendi"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi"),
        @ApiResponse(responseCode = "404", description = "Pet bulunamadı")
    })
    public ResponseEntity<PetResponse> updatePet(
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
        return ResponseEntity.ok(PetResponse.fromEntity(petService.updatePet(id, request)));
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

    private boolean isRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getAuthorities() == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> role.equals(a.getAuthority()));
    }
}
