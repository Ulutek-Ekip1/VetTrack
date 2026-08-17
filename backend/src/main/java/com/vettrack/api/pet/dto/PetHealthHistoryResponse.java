package com.vettrack.api.pet.dto;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.recommendation.Recommendation;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.visit.Visit;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PetHealthHistoryResponse {
    private UUID petId;
    private String name;
    private String species;
    private String breed;
    private String gender;
    private Double currentWeight;
    private String bloodType;
    private String microchipNo;
    private Boolean isSpayedOrNeutered;
    private String allergies;
    private String chronicIllnesses;
    private List<PetWeightHistoryResponse> weightHistory;
    private List<Visit> visits;
    private List<TreatmentEntry> treatments;
    private List<Recommendation> recommendations;

    public static PetHealthHistoryResponse from(
            Pet pet,
            List<PetWeightHistoryResponse> weightHistory,
            List<Visit> visits,
            List<TreatmentEntry> treatments,
            List<Recommendation> recommendations
    ) {
        return PetHealthHistoryResponse.builder()
                .petId(pet.getId())
                .name(pet.getName())
                .species(pet.getSpecies())
                .breed(pet.getBreed())
                .gender(pet.getGender() != null ? pet.getGender().name() : null)
                .currentWeight(pet.getWeight())
                .bloodType(pet.getBloodType())
                .microchipNo(pet.getMicrochipNo())
                .isSpayedOrNeutered(pet.getIsSpayedOrNeutered())
                .allergies(pet.getAllergies())
                .chronicIllnesses(pet.getChronicIllnesses())
                .weightHistory(weightHistory)
                .visits(visits)
                .treatments(treatments)
                .recommendations(recommendations)
                .build();
    }
}
