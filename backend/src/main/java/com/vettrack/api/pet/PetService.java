package com.vettrack.api.pet;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.storage.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;
    private final StorageService storageService;

    // Görsel olarak karıştırılabilecek karakterler (0, O, 1, I, L) tamamen çıkarılmış 31 karakterlik güvenli alfabe
    private static final String ALPHANUMERIC = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Yeni bir evcil hayvan oluşturur.
     * Hayvan ilk kez kaydedilirken ömür boyu değişmeyecek 6 haneli benzersiz kod atanır.
     */
    @Transactional
    public Pet createPet(Pet pet) {
        pet.setUniqueCode(generateUniqueCode());
        return petRepository.save(pet);
    }

    /**
     * Hekimlerin veya kullanıcıların 6 haneli benzersiz kod ile arama yapmasını sağlar.
     * Parametredeki boşluklar temizlenir ve otomatik büyük harfe dönüştürülür.
     */
    @Transactional(readOnly = true)
    public Pet getPetByUniqueCode(String uniqueCode) {
        if (uniqueCode == null || uniqueCode.isBlank()) {
            throw new IllegalArgumentException("Arama kodu boş olamaz");
        }

        // Boşlukları temizle ve büyük harfe çevir
        String cleanedCode = uniqueCode.trim().toUpperCase();

        return petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(cleanedCode)
                .orElseThrow(() -> new ResourceNotFoundException("Bu koda sahip evcil hayvan bulunamadı: " + cleanedCode));
    }

    /**
     * ID ile tekil pet detayını getirir.
     */
    @Transactional(readOnly = true)
    public Pet getPetById(UUID id) {
        Pet pet = petRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + id));
        if (pet.getDeletedAt() != null) {
            throw new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + id);
        }
        return pet;
    }

    /**
     * Hayvan sahibinin tüm petlerini listeler.
     */
    @Transactional(readOnly = true)
    public List<Pet> getPetsByOwner(UUID ownerId) {
        return petRepository.findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(ownerId);
    }

    /**
     * Pet bilgilerini günceller.
     * Dikkat: uniqueCode asla güncellenmez/değiştirilmez!
     */
    /**
     * Pet bilgilerini kısmen günceller (partial update).
     * Sadece null olmayan alanlar güncellenir — API sözleşmesi gereği tüm alanlar opsiyoneldir.
     * Dikkat: uniqueCode asla güncellenmez, photoUrl bu endpoint üzerinden değiştirilmez
     * (bunun için POST /pets/{id}/photo kullanılır).
     */
    @Transactional
    public Pet updatePet(UUID id, Pet petDetails) {
        Pet existingPet = getPetById(id);

        if (petDetails.getName() != null) {
            existingPet.setName(petDetails.getName());
        }
        if (petDetails.getAge() != null) {
            existingPet.setAge(petDetails.getAge());
        }
        if (petDetails.getGender() != null) {
            existingPet.setGender(petDetails.getGender());
        }
        if (petDetails.getBreed() != null) {
            existingPet.setBreed(petDetails.getBreed());
        }

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

    /**
     * 6 haneli, çakışmasız ve güvenli alfabe kullanan kod üretir.
     */
    private String generateUniqueCode() {
        String code;
        do {
            StringBuilder sb = new StringBuilder(6);
            for (int i = 0; i < 6; i++) {
                sb.append(ALPHANUMERIC.charAt(RANDOM.nextInt(ALPHANUMERIC.length())));
            }
            code = sb.toString();
        } while (petRepository.existsByUniqueCode(code)); // Veritabanı çakışma kontrolü

        return code;
    }
}