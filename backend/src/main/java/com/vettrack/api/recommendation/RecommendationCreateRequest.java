package com.vettrack.api.recommendation;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RecommendationCreateRequest {
    @NotBlank private String type;
    @NotBlank private String description;
}
