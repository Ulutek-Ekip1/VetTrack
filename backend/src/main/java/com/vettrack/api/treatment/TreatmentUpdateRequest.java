package com.vettrack.api.treatment;

import lombok.Data;

@Data
public class TreatmentUpdateRequest {

    @jakarta.validation.constraints.Pattern(regexp = "^(medication|vaccine|surgery|xray|lab_result|note)$", message = "Geçersiz tedavi tipi")
    private String type;
    private String title;
    private String description;
    private TreatmentStatus status;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public TreatmentStatus getStatus() { return status; }
    public void setStatus(TreatmentStatus status) { this.status = status; }
}
