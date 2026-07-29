package com.vettrack.api.pet;

import org.springframework.web.multipart.MultipartFile;
import java.util.Map;

import io.swagger.v3.oas.annotations.Operation;
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
@RequestMapping("/pets")
@RequiredArgsConstructor
@Tag(name = "Pet Yönetimi", description = "Evcil hayvan kayıt, güncelleme, listeleme ve benzersiz kod ile arama API'leri")
public class PetController {

    private final PetService petService;

    @PostMapping
    @Operation(summary = "Yeni Pet Ekle", description = "Sisteme yeni bir pet kaydeder ve otomatik olarak 6 haneli benzersiz kod üretir.")
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
    @Operation(summary = "Sahibin Petlerini Listele", description = "JWT'den alınan ownerId ile o kullanıcıya ait tüm petleri listeler.")
    public ResponseEntity<List<Pet>> getCurrentUserPets(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(petService.getPetsByOwner(ownerId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "ID ile Pet Getir", description = "Tekil pet bilgilerini ID üzerinden getirir.")
    public ResponseEntity<Pet> getPetById(@PathVariable UUID id) {
        return ResponseEntity.ok(petService.getPetById(id));
    }

    @GetMapping("/code/{uniqueCode}")
    @Operation(summary = "Benzersiz Kod ile Pet Bul", description = "Hekimlerin 6 haneli unique_code ile arama yapmasını sağlar.")
    public ResponseEntity<Pet> getPetByUniqueCode(@PathVariable String uniqueCode) {
        return ResponseEntity.ok(petService.getPetByUniqueCode(uniqueCode));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Pet Bilgilerini Güncelle", description = "Pet profil bilgilerini günceller. uniqueCode asla değişmez.")
    public ResponseEntity<Pet> updatePet(@PathVariable UUID id, @Valid @RequestBody PetUpdateRequest request) {
        Pet petDetails = Pet.builder()
                .name(request.getName())
                .photoUrl(request.getPhotoUrl())
                .age(request.getAge())
                .gender(request.getGender())
                .breed(request.getBreed())
                .build();

        return ResponseEntity.ok(petService.updatePet(id, petDetails));
    }

    @PostMapping("/{id}/photo")
    @Operation(summary = "Pet Fotoğrafı Yükle", description = "Fotoğrafı Supabase Storage'a yükler. Max 15MB, JPEG/PNG/WebP.")
    public ResponseEntity<Map<String, String>> uploadPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
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
    @Operation(summary = "Pet Sil (Soft Delete)", description = "Hayvanı pasife alır. Tıbbi geçmiş saklanır, sahibe görünmez (EC-05).")
    public ResponseEntity<Void> deletePet(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        petService.softDeletePet(id, ownerId);
        return ResponseEntity.noContent().build();
    }
}