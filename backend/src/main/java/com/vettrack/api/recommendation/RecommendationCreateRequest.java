package com.vettrack.api.recommendation;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationCreateRequest {

    private UUID visitId;

    @NotBlank(message = "Tavsiye türü (mama, kum, egzersiz, genel vb.) zorunludur.")
    private String type;

    @NotBlank(message = "Tavsiye açıklaması zorunludur.")
    private String description;
}
