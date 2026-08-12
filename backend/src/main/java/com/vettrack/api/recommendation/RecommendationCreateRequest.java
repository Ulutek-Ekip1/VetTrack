package com.vettrack.api.recommendation;

import jakarta.validation.constraints.NotBlank;
<<<<<<< HEAD
import lombok.Data;

@Data
public class RecommendationCreateRequest {
    @NotBlank private String type;
    @NotBlank private String description;
=======
import jakarta.validation.constraints.NotNull;
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

    @NotNull(message = "Ziyaret (visitId) zorunludur.")
    private UUID visitId;

    @NotBlank(message = "Tavsiye türü (mama, kum, egzersiz, genel vb.) zorunludur.")
    private String type;

    @NotBlank(message = "Tavsiye açıklaması zorunludur.")
    private String description;
>>>>>>> 0266a18 (feat: Gemini AI entegrasyonu, acil durum güvenlik katmanı ve testler eklendi)
}
