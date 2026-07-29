package com.vettrack.api.pet;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/pets")
@RequiredArgsConstructor
@Tag(name = "Pet Yönetimi", description = "Evcil hayvan kayıt, güncelleme, listeleme ve benzersiz kod ile arama API'leri")
public class PetController {

    private final PetService petService;

    @PostMapping
    @Operation(summary = "Yeni Pet Ekle", description = "Sisteme yeni bir pet kaydeder ve otomatik olarak 6 haneli benzersiz kod üretir.")
    public ResponseEntity<Pet> createPet(@Valid @RequestBody PetCreateRequest request) {
        Pet pet = Pet.builder()
                .ownerId(request.getOwnerId())
                .name(request.getName())
                .photoUrl(request.getPhotoUrl())
                .age(request.getAge())
                .gender(request.getGender())
                .breed(request.getBreed())
                .build();

        Pet createdPet = petService.createPet(pet);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPet);
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

    @GetMapping("/owner/{ownerId}")
    @Operation(summary = "Sahibinin Petlerini Listele", description = "Belirtilen owner_id'ye ait tüm petleri listeler.")
    public ResponseEntity<List<Pet>> getPetsByOwner(@PathVariable UUID ownerId) {
        return ResponseEntity.ok(petService.getPetsByOwner(ownerId));
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
}