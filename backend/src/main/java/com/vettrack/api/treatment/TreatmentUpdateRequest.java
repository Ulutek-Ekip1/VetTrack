package com.vettrack.api.treatment;

import lombok.Data;

@Data
public class TreatmentUpdateRequest {

    @jakarta.validation.constraints.Pattern(regexp = "^(medication|vaccine|surgery|xray|lab_result|note)$", message = "Geçersiz tedavi tipi")
    private String type;
    private String title;
    private String description;
    private TreatmentStatus status;
}
