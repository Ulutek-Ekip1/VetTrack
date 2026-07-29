package com.vettrack.api.pet;

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

    // Görsel olarak karıştırılabilecek karakterler (0, O, 1, I, L) çıkarılmış 31 karakterlik güvenli alfabe
    private static final String ALPHANUMERIC = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
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
     */
    @Transactional(readOnly = true)
    public Pet getPetByUniqueCode(String uniqueCode) {
        return petRepository.findByUniqueCodeIgnoreCase(uniqueCode)
                .orElseThrow(() -> new ResourceNotFoundException("Bu koda sahip evcil hayvan bulunamadı: " + uniqueCode));
    }

    /**
     * ID ile tekil pet detayını getirir.
     */
    @Transactional(readOnly = true)
    public Pet getPetById(UUID id) {
        return petRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + id));
    }

    /**
     * Hayvan sahibinin tüm petlerini listeler.
     */
    @Transactional(readOnly = true)
    public List<Pet> getPetsByOwner(UUID ownerId) {
        return petRepository.findByOwnerId(ownerId);
    }

    /**
     * Pet bilgilerini günceller.
     * Dikkat: uniqueCode asla güncellenmez/değiştirilmez!
     */
    @Transactional
    public Pet updatePet(UUID id, Pet petDetails) {
        Pet existingPet = getPetById(id);

        existingPet.setName(petDetails.getName());
        existingPet.setPhotoUrl(petDetails.getPhotoUrl());
        existingPet.setAge(petDetails.getAge());
        existingPet.setGender(petDetails.getGender());
        existingPet.setBreed(petDetails.getBreed());

        return petRepository.save(existingPet);
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
