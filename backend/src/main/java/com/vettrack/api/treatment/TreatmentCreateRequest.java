package com.vettrack.api.treatment;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TreatmentCreateRequest {

    @NotBlank(message = "Tedavi tipi boş olamaz")
    @jakarta.validation.constraints.Pattern(regexp = "^(medication|vaccine|surgery|xray|lab_result|note)$", message = "Geçersiz tedavi tipi")
    private String type;

    @NotBlank(message = "Başlık boş olamaz")
    private String title;

    private String description;
    private String attachmentUrl;
    private TreatmentStatus status;
}
