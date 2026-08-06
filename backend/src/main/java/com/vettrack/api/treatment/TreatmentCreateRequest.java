package com.vettrack.api.treatment;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TreatmentCreateRequest {

    @NotBlank(message = "Tedavi tipi boş olamaz")
    private String entryType;

    @NotBlank(message = "Başlık boş olamaz")
    private String title;

    private String description;
    private String attachmentUrl;
    private TreatmentStatus status;
}