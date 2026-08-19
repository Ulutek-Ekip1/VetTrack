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

    public static PetHealthHistoryResponseBuilder builder() {
        return new PetHealthHistoryResponseBuilder();
    }

    public static class PetHealthHistoryResponseBuilder {
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

        public PetHealthHistoryResponseBuilder petId(UUID petId) { this.petId = petId; return this; }
        public PetHealthHistoryResponseBuilder name(String name) { this.name = name; return this; }
        public PetHealthHistoryResponseBuilder species(String species) { this.species = species; return this; }
        public PetHealthHistoryResponseBuilder breed(String breed) { this.breed = breed; return this; }
        public PetHealthHistoryResponseBuilder gender(String gender) { this.gender = gender; return this; }
        public PetHealthHistoryResponseBuilder currentWeight(Double currentWeight) { this.currentWeight = currentWeight; return this; }
        public PetHealthHistoryResponseBuilder bloodType(String bloodType) { this.bloodType = bloodType; return this; }
        public PetHealthHistoryResponseBuilder microchipNo(String microchipNo) { this.microchipNo = microchipNo; return this; }
        public PetHealthHistoryResponseBuilder isSpayedOrNeutered(Boolean isSpayedOrNeutered) { this.isSpayedOrNeutered = isSpayedOrNeutered; return this; }
        public PetHealthHistoryResponseBuilder allergies(String allergies) { this.allergies = allergies; return this; }
        public PetHealthHistoryResponseBuilder chronicIllnesses(String chronicIllnesses) { this.chronicIllnesses = chronicIllnesses; return this; }
        public PetHealthHistoryResponseBuilder weightHistory(List<PetWeightHistoryResponse> weightHistory) { this.weightHistory = weightHistory; return this; }
        public PetHealthHistoryResponseBuilder visits(List<VisitSummaryDto> visits) { this.visits = visits; return this; }
        public PetHealthHistoryResponseBuilder treatments(List<TreatmentSummaryDto> treatments) { this.treatments = treatments; return this; }
        public PetHealthHistoryResponseBuilder recommendations(List<RecommendationSummaryDto> recommendations) { this.recommendations = recommendations; return this; }

        public PetHealthHistoryResponse build() {
            PetHealthHistoryResponse r = new PetHealthHistoryResponse();
            r.petId = this.petId;
            r.name = this.name;
            r.species = this.species;
            r.breed = this.breed;
            r.gender = this.gender;
            r.currentWeight = this.currentWeight;
            r.bloodType = this.bloodType;
            r.microchipNo = this.microchipNo;
            r.isSpayedOrNeutered = this.isSpayedOrNeutered;
            r.allergies = this.allergies;
            r.chronicIllnesses = this.chronicIllnesses;
            r.weightHistory = this.weightHistory;
            r.visits = this.visits;
            r.treatments = this.treatments;
            r.recommendations = this.recommendations;
            return r;
        }
    }

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

        public static VisitSummaryDtoBuilder builder() {
            return new VisitSummaryDtoBuilder();
        }

        public static class VisitSummaryDtoBuilder {
            private UUID id;
            private UUID clinicId;
            private UUID vetStaffId;
            private String status;
            private String chiefComplaint;
            private OffsetDateTime startedAt;
            private OffsetDateTime endedAt;

            public VisitSummaryDtoBuilder id(UUID id) { this.id = id; return this; }
            public VisitSummaryDtoBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
            public VisitSummaryDtoBuilder vetStaffId(UUID vetStaffId) { this.vetStaffId = vetStaffId; return this; }
            public VisitSummaryDtoBuilder status(String status) { this.status = status; return this; }
            public VisitSummaryDtoBuilder chiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; return this; }
            public VisitSummaryDtoBuilder startedAt(OffsetDateTime startedAt) { this.startedAt = startedAt; return this; }
            public VisitSummaryDtoBuilder endedAt(OffsetDateTime endedAt) { this.endedAt = endedAt; return this; }

            public VisitSummaryDto build() {
                VisitSummaryDto v = new VisitSummaryDto();
                v.id = this.id;
                v.clinicId = this.clinicId;
                v.vetStaffId = this.vetStaffId;
                v.status = this.status;
                v.chiefComplaint = this.chiefComplaint;
                v.startedAt = this.startedAt;
                v.endedAt = this.endedAt;
                return v;
            }
        }

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

        public static TreatmentSummaryDtoBuilder builder() {
            return new TreatmentSummaryDtoBuilder();
        }

        public static class TreatmentSummaryDtoBuilder {
            private UUID id;
            private UUID visitId;
            private String type;
            private String title;
            private String description;
            private String status;
            private OffsetDateTime startDate;
            private OffsetDateTime endDate;

            public TreatmentSummaryDtoBuilder id(UUID id) { this.id = id; return this; }
            public TreatmentSummaryDtoBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
            public TreatmentSummaryDtoBuilder type(String type) { this.type = type; return this; }
            public TreatmentSummaryDtoBuilder title(String title) { this.title = title; return this; }
            public TreatmentSummaryDtoBuilder description(String description) { this.description = description; return this; }
            public TreatmentSummaryDtoBuilder status(String status) { this.status = status; return this; }
            public TreatmentSummaryDtoBuilder startDate(OffsetDateTime startDate) { this.startDate = startDate; return this; }
            public TreatmentSummaryDtoBuilder endDate(OffsetDateTime endDate) { this.endDate = endDate; return this; }

            public TreatmentSummaryDto build() {
                TreatmentSummaryDto t = new TreatmentSummaryDto();
                t.id = this.id;
                t.visitId = this.visitId;
                t.type = this.type;
                t.title = this.title;
                t.description = this.description;
                t.status = this.status;
                t.startDate = this.startDate;
                t.endDate = this.endDate;
                return t;
            }
        }

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

        public static RecommendationSummaryDtoBuilder builder() {
            return new RecommendationSummaryDtoBuilder();
        }

        public static class RecommendationSummaryDtoBuilder {
            private UUID id;
            private UUID visitId;
            private String type;
            private String description;
            private OffsetDateTime createdAt;

            public static RecommendationSummaryDtoBuilder builder() {
                return new RecommendationSummaryDtoBuilder();
            }

            public RecommendationSummaryDtoBuilder id(UUID id) { this.id = id; return this; }
            public RecommendationSummaryDtoBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
            public RecommendationSummaryDtoBuilder type(String type) { this.type = type; return this; }
            public RecommendationSummaryDtoBuilder description(String description) { this.description = description; return this; }
            public RecommendationSummaryDtoBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

            public RecommendationSummaryDto build() {
                RecommendationSummaryDto r = new RecommendationSummaryDto();
                r.id = this.id;
                r.visitId = this.visitId;
                r.type = this.type;
                r.description = this.description;
                r.createdAt = this.createdAt;
                return r;
            }
        }

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