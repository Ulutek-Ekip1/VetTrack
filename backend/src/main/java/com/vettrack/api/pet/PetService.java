package com.vettrack.api.pet;

import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.pet.dto.PetHealthHistoryResponse;
import com.vettrack.api.pet.dto.PetWeightHistoryResponse;
import com.vettrack.api.recommendation.Recommendation;
import com.vettrack.api.recommendation.RecommendationRepository;
import com.vettrack.api.storage.StorageService;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.treatment.TreatmentEntryRepository;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;
    private final PetWeightHistoryRepository petWeightHistoryRepository;
    private final VisitRepository visitRepository;
    private final TreatmentEntryRepository treatmentEntryRepository;
    private final RecommendationRepository recommendationRepository;
    private final StorageService storageService;

    private static final String ALPHANUMERIC = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    private static final SecureRandom RANDOM = new SecureRandom();

    @Transactional
    public Pet createPet(Pet pet) {
        pet.setUniqueCode(generateUniqueCode());
        Pet savedPet = petRepository.save(pet);
        if (savedPet.getWeight() != null) {
            recordWeight(savedPet.getId(), savedPet.getWeight(), LocalDate.now(), savedPet.getOwnerId());
        }
        return savedPet;
    }

    @Transactional(readOnly = true)
    public Pet getPetByUniqueCode(String uniqueCode) {
        if (uniqueCode == null || uniqueCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Arama kodu boş olamaz");
        }
        String cleanedCode = uniqueCode.trim().toUpperCase();
        return petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(cleanedCode)
                .orElseThrow(() -> new ResourceNotFoundException(ErrorCode.PET_NOT_FOUND, "Bu koda sahip evcil hayvan bulunamadı: " + cleanedCode));
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

    @Transactional(readOnly = true)
    public PetHealthHistoryResponse getPetHealthHistory(UUID petId) {
        Pet pet = getPetById(petId);
        List<PetWeightHistoryResponse> weightHistory = getWeightHistory(petId);
        List<Visit> visits = visitRepository.findByPetIdOrderByStartedAtDesc(petId);

        List<UUID> visitIds = visits.stream().map(Visit::getId).toList();
        List<TreatmentEntry> treatments = visitIds.isEmpty()
                ? List.of()
                : treatmentEntryRepository.findByVisitIdInOrderByCreatedAtDesc(visitIds);

        List<Recommendation> recommendations = visitIds.isEmpty()
                ? List.of()
                : recommendationRepository.findByVisitIdInOrderByCreatedAtDesc(visitIds);

        return PetHealthHistoryResponse.from(
                pet, weightHistory, visits, treatments, recommendations
        );
    }

    @Transactional
    public Pet updatePet(UUID id, PetUpdateRequest request) {
        Pet existingPet = getPetById(id);

        if (request.getName() != null) {
            if (request.getName().isBlank()) {
                throw new IllegalArgumentException("Pet adı boş olamaz");
            }
            existingPet.setName(request.getName());
        }
        if (request.getSpecies() != null) existingPet.setSpecies(request.getSpecies());
        if (request.getBreed() != null) existingPet.setBreed(request.getBreed());
        if (request.getGender() != null) existingPet.setGender(request.getGender());
        if (request.getBirthDate() != null) existingPet.setBirthDate(request.getBirthDate());
        if (request.getEstimatedBirthYear() != null) existingPet.setEstimatedBirthYear(request.getEstimatedBirthYear());
        if (request.getWeight() != null) {
            existingPet.setWeight(request.getWeight());
            recordWeight(existingPet.getId(), request.getWeight(), LocalDate.now(), existingPet.getOwnerId());
        }
        if (request.getMicrochipNo() != null) existingPet.setMicrochipNo(request.getMicrochipNo());
        if (request.getIsSpayedOrNeutered() != null) existingPet.setIsSpayedOrNeutered(request.getIsSpayedOrNeutered());
        if (request.getBloodType() != null) existingPet.setBloodType(request.getBloodType());
        if (request.getColor() != null) existingPet.setColor(request.getColor());
        if (request.getAllergies() != null) existingPet.setAllergies(request.getAllergies());
        if (request.getChronicIllnesses() != null) existingPet.setChronicIllnesses(request.getChronicIllnesses());

        return petRepository.save(existingPet);
    }

    @Transactional(readOnly = true)
    public List<PetWeightHistoryResponse> getWeightHistory(UUID petId) {
        getPetById(petId);
        return petWeightHistoryRepository.findByPetIdOrderByRecordedAtAscCreatedAtAsc(petId).stream()
                .map(PetWeightHistoryResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public Page<PetWeightHistoryResponse> getWeightHistoryPaginated(UUID petId, Pageable pageable) {
        getPetById(petId);
        return petWeightHistoryRepository.findByPetIdOrderByRecordedAtAscCreatedAtAsc(petId, pageable)
                .map(PetWeightHistoryResponse::fromEntity);
    }

    @Transactional
    public void recordWeight(UUID petId, Double weight, LocalDate date, UUID recordedBy) {
        if (weight == null) return;
        if (Double.isNaN(weight) || Double.isInfinite(weight) || weight <= 0 || weight > 2000.0) {
            throw new IllegalArgumentException("Kilo değeri 0'dan büyük ve en fazla 2000 kg olmalıdır");
        }
        
        var lastRecord = petWeightHistoryRepository.findTopByPetIdOrderByRecordedAtDescCreatedAtDesc(petId);
        if (lastRecord.isPresent() && lastRecord.get().getWeight().equals(weight)) {
            return;
        }
        
        OffsetDateTime recordedAt;
        if (date == null || date.isEqual(LocalDate.now(ZoneOffset.UTC))) {
            recordedAt = OffsetDateTime.now(ZoneOffset.UTC);
        } else {
            recordedAt = date.atStartOfDay().atOffset(ZoneOffset.UTC);
        }
        
        PetWeightHistory history = PetWeightHistory.builder()
                .petId(petId)
                .weight(weight)
                .recordedAt(recordedAt)
                .recordedBy(recordedBy)
                .build();
        petWeightHistoryRepository.save(history);
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
    public void deletePetPhoto(UUID petId, UUID ownerId) {
        Pet pet = getPetById(petId);
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new AccessDeniedException("Bu hayvan size ait değil");
        }
        if (pet.getPhotoUrl() == null) {
            return;
        }
        storageService.deletePetPhoto(petId);
        pet.setPhotoUrl(null);
        petRepository.save(pet);
    }

    @Transactional
    public void softDeletePet(UUID petId, UUID ownerId) {
        Pet pet = getPetById(petId);
        if (!pet.getOwnerId().equals(ownerId)) {
            throw new AccessDeniedException("Bu hayvan size ait değil");
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