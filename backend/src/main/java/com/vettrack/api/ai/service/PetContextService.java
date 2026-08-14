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
                sb.append("=== KULLANICININ SİSTEMDE KAYITLI EVCİL HAYVANLARI ===\n");
                for (Pet pet : ownerPets) {
                    sb.append(formatSinglePetContext(pet)).append("\n");
                }
                return sb.toString();
            }
        }

        return "Sistemde kayıtlı belirli bir evcil hayvan bilgisi bulunmamaktadır. Genel veterinerlik bilgisi ile yardımcı olunuz.";
    }

    private String formatSinglePetContext(Pet pet) {
        StringBuilder sb = new StringBuilder();
        sb.append("=== EVCİL HAYVAN PROFİLİ VE TIBBİ BAĞLAMI ===\n");
        sb.append("Adı: ").append(pet.getName()).append("\n");
        sb.append("Tür: ").append(pet.getSpecies()).append("\n");
        sb.append("Irk: ").append(pet.getBreed() != null ? pet.getBreed() : "Bilinmiyor").append("\n");
        sb.append("Cinsiyet: ").append(pet.getGender() != null ? pet.getGender() : "Bilinmiyor").append("\n");

        if (pet.getBirthDate() != null) {
            int ageYears = Period.between(pet.getBirthDate(), LocalDate.now()).getYears();
            sb.append("Doğum Tarihi: ").append(pet.getBirthDate()).append(" (Yaklaşık ").append(ageYears).append(" yaşında)\n");
        } else if (pet.getEstimatedBirthYear() != null) {
            int ageYears = LocalDate.now().getYear() - pet.getEstimatedBirthYear();
            sb.append("Tahmini Yaş: ").append(ageYears).append(" yaşında\n");
        }

        // Fetch recent visits and treatment entries
        List<Visit> visits = visitRepository.findByPetIdOrderByStartedAtDesc(pet.getId());
        List<TreatmentEntry> allTreatments = new ArrayList<>();

        for (Visit visit : visits) {
            List<TreatmentEntry> entries = treatmentEntryRepository.findByVisitIdOrderByStartDateDesc(visit.getId());
            allTreatments.addAll(entries);
        }

        if (!allTreatments.isEmpty()) {
            sb.append("\n=== GEÇMİŞ TIBBİ TEDAVİ VE AŞI KAYITLARI ===\n");
            int count = 0;
            for (TreatmentEntry entry : allTreatments) {
                if (count++ >= 10) break; // Limit to 10 most recent entries for context budget
                sb.append("- [").append(entry.getType()).append("] ")
                        .append(entry.getTitle())
                        .append(" (Durum: ").append(entry.getStatus()).append(")");
                if (entry.getDescription() != null && !entry.getDescription().isBlank()) {
                    sb.append(": ").append(entry.getDescription());
                }
                sb.append("\n");
            }
        } else {
            sb.append("\nKayıtlı aktif veya geçmiş tedavi kaydı bulunmamaktadır.\n");
        }

        sb.append("=============================================\n");
        return sb.toString();
    }
}
