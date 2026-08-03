package com.vettrack.api.treatment;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Tedavi girişi ekleme isteği.
 * API sözleşmesi: POST /visits/{visitId}/treatments
 */
@Data
public class TreatmentCreateRequest {

    @NotBlank(message = "Tedavi tipi boş olamaz")
    private String type;

    @NotBlank(message = "Başlık boş olamaz")
    private String title;

    private String description;

    private String attachmentUrl;

    private TreatmentStatus status;
}