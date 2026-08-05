package com.vettrack.api.pet;

import com.vettrack.api.storage.StorageService;
import org.springframework.web.multipart.MultipartFile;
import java.time.OffsetDateTime;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;
    private final StorageService storageService;

    private static final String ALPHANUMERIC = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final SecureRandom RANDOM = new SecureRandom();

    @Transactional
    public Pet createPet(Pet pet) {
        pet.setUniqueCode(generateUniqueCode());
        return petRepository.save(pet);
    }

    @Transactional(readOnly = true)
    public Pet getPetByUniqueCode(String uniqueCode) {
        return petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(uniqueCode)
                .orElseThrow(() -> new ResourceNotFoundException("Bu koda sahip evcil hayvan bulunamadı: " + uniqueCode));
    }

    @Transactional(readOnly = true)
    public Pet getPetById(UUID id) {
        Pet pet = petRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + id));
        if (pet.getDeletedAt() != null) {
            throw new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + id);
        }
        return pet;
    }

    @Transactional(readOnly = true)
    public List<Pet> getPetsByOwner(UUID ownerId) {
        return petRepository.findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(ownerId);
    }

    @Transactional
    public Pet updatePet(UUID id, PetUpdateRequest request) {
        Pet existingPet = getPetById(id);

        if (request.getName() != null) existingPet.setName(request.getName());
        if (request.getSpecies() != null) existingPet.setSpecies(request.getSpecies());
        if (request.getBreed() != null) existingPet.setBreed(request.getBreed());
        if (request.getGender() != null) existingPet.setGender(request.getGender());
        if (request.getBirthDate() != null) existingPet.setBirthDate(request.getBirthDate());
        if (request.getEstimatedBirthYear() != null) existingPet.setEstimatedBirthYear(request.getEstimatedBirthYear());

        return petRepository.save(existingPet);
    }

    @Transactional
    public String uploadPhoto(UUID petId, MultipartFile file) {
        Pet pet = getPetById(petId);
        String photoUrl = storageService.uploadPetPhoto(file, petId);
        pet.setPhotoUrl(photoUrl);
        petRepository.save(pet);
        return photoUrl;
    }

    @Transactional
    public void softDeletePet(UUID petId, UUID ownerId) {
        Pet pet = getPetById(petId);
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new org.springframework.security.access.AccessDeniedException("Bu hayvan size ait değil");
        }
        if (pet.getDeletedAt() != null) {
            throw new ResourceNotFoundException("Evcil hayvan zaten silinmiş");
        }
        pet.setDeletedAt(OffsetDateTime.now());
        petRepository.save(pet);
    }

    private String generateUniqueCode() {
        String code;
        do {
            StringBuilder sb = new StringBuilder(6);
            for (int i = 0; i < 6; i++) {
                sb.append(ALPHANUMERIC.charAt(RANDOM.nextInt(ALPHANUMERIC.length())));
            }
            code = sb.toString();
        } while (petRepository.existsByUniqueCode(code));
        return code;
    }
}