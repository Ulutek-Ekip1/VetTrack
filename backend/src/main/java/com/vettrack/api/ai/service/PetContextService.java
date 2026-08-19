package com.vettrack.api.ai.service;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.treatment.TreatmentEntryRepository;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PetContextService {

    private final PetRepository petRepository;
    private final VisitRepository visitRepository;
    private final TreatmentEntryRepository treatmentEntryRepository;

    @Transactional(readOnly = true)
    public String buildPetContext(UUID petId) {
        return buildOwnerPetsContext(null, petId);
    }

    @Transactional(readOnly = true)
    public String buildOwnerPetsContext(UUID ownerId, UUID petId) {
        // 1. Explicit petId supplied
        if (petId != null) {
            Optional<Pet> petOpt = petRepository.findById(petId);
            if (petOpt.isPresent()) {
                Pet pet = petOpt.get();
                if (pet.getDeletedAt() != null || Boolean.FALSE.equals(pet.getIsActive())) {
                    return "Belirtilen evcil hayvan kaydı aktif değil veya silinmiş.";
                }
                return formatSinglePetContext(pet);
            }
        }

        // 2. Fallback: Auto-resolve owner's registered pets if petId was not provided
        if (ownerId != null) {
            List<Pet> ownerPets = petRepository.findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(ownerId);
            if (!ownerPets.isEmpty()) {
                StringBuilder sb = new StringBuilder();
                sb.append("=== EVCİL HAYVAN TIBBİ PROFİLLERİ ===\n");
                for (Pet pet : ownerPets) {
                    sb.append(formatSinglePetContext(pet)).append("\n");
                }
                return sb.toString();
            }
        }

        return "Sistemde kayıtlı belirli bir evcil hayvan bilgisi bulunmamaktadır. Genel veterinerlik danışmanlığı ile yardımcı olunuz.";
    }

    private String formatSinglePetContext(Pet pet) {
        StringBuilder sb = new StringBuilder();
        sb.append("--- Hayvan Profili ---\n");
        sb.append("Adı: ").append(pet.getName()).append("\n");
        sb.append("Tür: ").append(pet.getSpecies()).append("\n");
        sb.append("Irk: ").append(pet.getBreed() != null ? pet.getBreed() : "Bilinmiyor").append("\n");
        sb.append("Cinsiyet: ").append(pet.getGender() != null ? pet.getGender() : "Bilinmiyor").append("\n");
        sb.append("Kısırlaştırılma Durumu: ").append(Boolean.TRUE.equals(pet.getIsSpayedOrNeutered()) ? "Kısırlaştırılmış" : "Kısırlaştırılmamış/Bilinmiyor").append("\n");

        if (pet.getWeight() != null) {
            sb.append("Kilo: ").append(pet.getWeight()).append(" kg\n");
        }

        if (pet.getAllergies() != null && !pet.getAllergies().isBlank()) {
            sb.append("Alerjiler: ").append(pet.getAllergies()).append("\n");
        }

        if (pet.getChronicIllnesses() != null && !pet.getChronicIllnesses().isBlank()) {
            sb.append("Kronik Rahatsızlıklar: ").append(pet.getChronicIllnesses()).append("\n");
        }

        if (pet.getBirthDate() != null) {
            int ageYears = Period.between(pet.getBirthDate(), LocalDate.now()).getYears();
            sb.append("Yaş: Yaklaşık ").append(ageYears).append(" yaşında\n");
        } else if (pet.getEstimatedBirthYear() != null) {
            int ageYears = LocalDate.now().getYear() - pet.getEstimatedBirthYear();
            sb.append("Yaş: Yaklaşık ").append(ageYears).append(" yaşında\n");
        }

        // Fetch recent visits and treatment entries (strictly minimal metadata, no staff PII)
        List<Visit> visits = visitRepository.findByPetIdOrderByStartedAtDesc(pet.getId());
        List<TreatmentEntry> allTreatments = new ArrayList<>();

        for (Visit visit : visits) {
            List<TreatmentEntry> entries = treatmentEntryRepository.findByVisitIdOrderByStartDateDesc(visit.getId());
            allTreatments.addAll(entries);
        }

        if (!allTreatments.isEmpty()) {
            sb.append("Geçmiş Tıbbi/Aşı Kayıtları:\n");
            int count = 0;
            for (TreatmentEntry entry : allTreatments) {
                if (count++ >= 8) break; // Token & privacy budget limit
                sb.append("- [").append(entry.getType()).append("] ").append(entry.getTitle());
                if (entry.getDescription() != null && !entry.getDescription().isBlank()) {
                    sb.append(" (").append(entry.getDescription()).append(")");
                }
                sb.append("\n");
            }
        }

        return sb.toString();
    }
}
