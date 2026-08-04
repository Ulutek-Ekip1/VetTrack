package com.vettrack.api.pet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/pets")
@RequiredArgsConstructor
@Tag(name = "Pet Yönetimi", description = "Evcil hayvan kayıt, güncelleme, listeleme ve benzersiz kod ile arama API'leri")
public class PetController {

    private final PetService petService;

    @PostMapping
    @Operation(
        summary = "Yeni Pet Ekle", 
        description = "Sisteme yeni bir pet kaydeder ve otomatik olarak 6 haneli benzersiz kod üretir (FR-04).",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Pet başarıyla oluşturuldu"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek parametreleri veya doğrulama hatası (Validation Failure)"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "409", description = "Benzersiz kod çakışması veya veri çakışması (Conflict)")
    })
    public ResponseEntity<Pet> createPet(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody PetCreateRequest request
    ) {
        Pet pet = Pet.builder()
                .ownerId(UUID.fromString(jwt.getSubject()))
                .name(request.getName())
                .photoUrl(request.getPhotoUrl())
                .age(request.getAge())
                .gender(request.getGender())
                .breed(request.getBreed())
                .build();

        Pet createdPet = petService.createPet(pet);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPet);
    }

    @GetMapping
    @Operation(
        summary = "Sahibin Petlerini Listele", 
        description = "JWT'den alınan ownerId ile o kullanıcıya ait tüm aktif (soft delete yapılmamış) petleri listeler (FR-13).",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet listesi başarıyla getirildi"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)")
    })
    public ResponseEntity<List<Pet>> getCurrentUserPets(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(petService.getPetsByOwner(ownerId));
    }

    @GetMapping("/{id}")
    @Operation(
        summary = "ID ile Pet Getir", 
        description = "Tekil pet bilgilerini ID üzerinden getirir.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet bilgisi başarıyla getirildi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz ID formatı"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi (Bu hayvan başka bir sahibe ait)"),
        @ApiResponse(responseCode = "404", description = "Evcil hayvan bulunamadı veya silinmiş")
    })
    public ResponseEntity<Pet> getPetById(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Pet UUID ID'si", required = true) @PathVariable UUID id
    ) {
        Pet pet = petService.getPetById(id);
        if (jwt != null) {
            String role = jwt.getClaimAsString("role");
            boolean isVetOrAdmin = "vet".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role) || "VET".equalsIgnoreCase(role);
            UUID ownerId = UUID.fromString(jwt.getSubject());
            if (!isVetOrAdmin && !pet.getOwnerId().equals(ownerId)) {
                throw new org.springframework.security.access.AccessDeniedException("Bu hayvan size ait değil");
            }
        }
        return ResponseEntity.ok(pet);
    }

    @GetMapping("/code/{uniqueCode}")
    @Operation(
        summary = "Benzersiz Kod ile Pet Bul", 
        description = "Hekimlerin 6 haneli unique_code ile arama yapmasını sağlar (Case-insensitive).",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet bilgisi bulundu"),
        @ApiResponse(responseCode = "400", description = "Geçersiz kod formatı"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "404", description = "Bu koda sahip evcil hayvan bulunamadı")
    })
    public ResponseEntity<Pet> getPetByUniqueCode(
            @Parameter(description = "6 haneli benzersiz pet kodu", required = true) @PathVariable String uniqueCode
    ) {
        return ResponseEntity.ok(petService.getPetByUniqueCode(uniqueCode));
    }

    @PutMapping("/{id}")
    @Operation(
        summary = "Pet Bilgilerini Güncelle", 
        description = "Pet profil bilgilerini günceller. uniqueCode asla değişmez.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pet başarıyla güncellendi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek veya doğrulama hatası"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi (Bu hayvan başka bir sahibe ait)"),
        @ApiResponse(responseCode = "404", description = "Evcil hayvan bulunamadı veya silinmiş")
    })
    public ResponseEntity<Pet> updatePet(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Pet UUID ID'si", required = true) @PathVariable UUID id, 
            @Valid @RequestBody PetUpdateRequest request
    ) {
        Pet pet = petService.getPetById(id);
        if (jwt != null) {
            UUID ownerId = UUID.fromString(jwt.getSubject());
            if (!pet.getOwnerId().equals(ownerId)) {
                throw new org.springframework.security.access.AccessDeniedException("Bu hayvan size ait değil");
            }
        }
        Pet petDetails = Pet.builder()
                .name(request.getName())
                .age(request.getAge())
                .gender(request.getGender())
                .breed(request.getBreed())
                .build();

        return ResponseEntity.ok(petService.updatePet(id, petDetails));
    }

    @PostMapping(value = "/{id}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(
        summary = "Pet Fotoğrafı Yükle", 
        description = "Fotoğrafı Supabase Storage'a yükler (FR-09). Max 15MB (EC-06). Kabul edilen tipler: JPEG, PNG, WebP.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Fotoğraf başarıyla yüklendi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz dosya veya parametre"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi (Bu hayvan başka bir sahibe ait)"),
        @ApiResponse(responseCode = "404", description = "Evcil hayvan bulunamadı"),
        @ApiResponse(responseCode = "413", description = "Dosya boyutu 15MB sınırını aşıyor (EC-06)"),
        @ApiResponse(responseCode = "415", description = "Desteklenmeyen dosya tipi (Sadece JPEG, PNG, WebP)")
    })
    public ResponseEntity<Map<String, String>> uploadPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Pet UUID ID'si", required = true) @PathVariable UUID id,
            @RequestParam("file") MultipartFile file
    ) {
        Pet pet = petService.getPetById(id);
        UUID ownerId = UUID.fromString(jwt.getSubject());
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new org.springframework.security.access.AccessDeniedException("Bu hayvan size ait değil");
        }

        String photoUrl = petService.uploadPhoto(id, file);
        return ResponseEntity.ok(Map.of("photoUrl", photoUrl));
    }

    @DeleteMapping("/{id}")
    @Operation(
        summary = "Pet Sil (Soft Delete)", 
        description = "Hayvanı pasife alır (EC-05). Tıbbi geçmiş saklanır, sahibe görünmez.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Pet başarıyla pasife alındı (soft delete)"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "403", description = "Erişim engellendi (Bu hayvan başka bir sahibe ait)"),
        @ApiResponse(responseCode = "404", description = "Evcil hayvan bulunamadı veya zaten silinmiş")
    })
    public ResponseEntity<Void> deletePet(
            @AuthenticationPrincipal Jwt jwt,
            @Parameter(description = "Pet UUID ID'si", required = true) @PathVariable UUID id
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        petService.softDeletePet(id, ownerId);
        return ResponseEntity.noContent().build();
    }
}