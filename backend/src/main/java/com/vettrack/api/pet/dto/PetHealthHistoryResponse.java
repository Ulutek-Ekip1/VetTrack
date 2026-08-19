package com.vettrack.api.pet.dto;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.recommendation.Recommendation;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.visit.Visit;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
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
    private List<VisitSummaryDto> visits;
    private List<TreatmentSummaryDto> treatments;
    private List<RecommendationSummaryDto> recommendations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VisitSummaryDto {
        private UUID id;
        private UUID clinicId;
        private UUID vetStaffId;
        private String status;
        private String chiefComplaint;
        private OffsetDateTime startedAt;
        private OffsetDateTime endedAt;

        public static VisitSummaryDto fromEntity(Visit visit) {
            if (visit == null) return null;
            return VisitSummaryDto.builder()
                    .id(visit.getId())
                    .clinicId(visit.getClinicId())
                    .vetStaffId(visit.getVetStaffId())
                    .status(visit.getStatus())
                    .chiefComplaint(visit.getChiefComplaint())
                    .startedAt(visit.getStartedAt())
                    .endedAt(visit.getEndedAt())
                    .build();
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TreatmentSummaryDto {
        private UUID id;
        private UUID visitId;
        private String type;
        private String title;
        private String description;
        private String status;
        private OffsetDateTime startDate;
        private OffsetDateTime endDate;

        public static TreatmentSummaryDto fromEntity(TreatmentEntry treatment) {
            if (treatment == null) return null;
            return TreatmentSummaryDto.builder()
                    .id(treatment.getId())
                    .visitId(treatment.getVisitId())
                    .type(treatment.getType())
                    .title(treatment.getTitle())
                    .description(treatment.getDescription())
                    .status(treatment.getStatus() != null ? treatment.getStatus().name() : null)
                    .startDate(treatment.getStartDate())
                    .endDate(treatment.getEndDate())
                    .build();
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecommendationSummaryDto {
        private UUID id;
        private UUID visitId;
        private String type;
        private String description;
        private OffsetDateTime createdAt;

        public static RecommendationSummaryDto fromEntity(Recommendation recommendation) {
            if (recommendation == null) return null;
            return RecommendationSummaryDto.builder()
                    .id(recommendation.getId())
                    .visitId(recommendation.getVisitId())
                    .type(recommendation.getType())
                    .description(recommendation.getDescription())
                    .createdAt(recommendation.getCreatedAt())
                    .build();
        }
    }

    public static PetHealthHistoryResponse from(
            Pet pet,
            List<PetWeightHistoryResponse> weightHistory,
            List<Visit> visits,
            List<TreatmentEntry> treatments,
            List<Recommendation> recommendations
    ) {
        List<VisitSummaryDto> visitDtos = visits != null
                ? visits.stream().map(VisitSummaryDto::fromEntity).toList()
                : List.of();

        List<TreatmentSummaryDto> treatmentDtos = treatments != null
                ? treatments.stream().map(TreatmentSummaryDto::fromEntity).toList()
                : List.of();

        List<RecommendationSummaryDto> recommendationDtos = recommendations != null
                ? recommendations.stream().map(RecommendationSummaryDto::fromEntity).toList()
                : List.of();

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
                .visits(visitDtos)
                .treatments(treatmentDtos)
                .recommendations(recommendationDtos)
                .build();
    }
}