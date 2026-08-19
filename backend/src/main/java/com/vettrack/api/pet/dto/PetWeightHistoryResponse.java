package com.vettrack.api.pet.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.vettrack.api.pet.PetWeightHistory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PetWeightHistoryResponse {

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;
    private Double weight;

    public static PetWeightHistoryResponseBuilder builder() {
        return new PetWeightHistoryResponseBuilder();
    }

    public static class PetWeightHistoryResponseBuilder {
        private LocalDate date;
        private Double weight;

        public PetWeightHistoryResponseBuilder date(LocalDate date) { this.date = date; return this; }
        public PetWeightHistoryResponseBuilder weight(Double weight) { this.weight = weight; return this; }

        public PetWeightHistoryResponse build() {
            PetWeightHistoryResponse r = new PetWeightHistoryResponse();
            r.date = this.date;
            r.weight = this.weight;
            return r;
        }
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }

    public static PetWeightHistoryResponse fromEntity(PetWeightHistory entity) {
        if (entity == null) {
            return null;
        }
        return PetWeightHistoryResponse.builder()
                .date(entity.getRecordedAt() != null ? entity.getRecordedAt().toLocalDate() : null)
                .weight(entity.getWeight())
                .build();
    }
}
