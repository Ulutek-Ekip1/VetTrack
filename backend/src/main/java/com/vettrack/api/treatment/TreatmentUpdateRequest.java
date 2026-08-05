package com.vettrack.api.treatment;

import lombok.Data;

@Data
public class TreatmentUpdateRequest {

    private String entryType;
    private String title;
    private String description;
    private String attachmentUrl;
    private TreatmentStatus status;
}