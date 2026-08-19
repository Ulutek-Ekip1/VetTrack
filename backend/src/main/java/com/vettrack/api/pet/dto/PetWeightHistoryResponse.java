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
