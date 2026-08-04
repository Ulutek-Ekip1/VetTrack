package com.vettrack.api.treatment;

import lombok.Data;

/**
 * Tedavi düzenleme isteği. Tüm alanlar opsiyoneldir (partial update).
 * API sözleşmesi: PUT /treatments/{id} — 15 dk pencere (EC-08).
 */
@Data
public class TreatmentUpdateRequest {

    private String type;
    private String title;
    private String description;
    private String attachmentUrl;
    private TreatmentStatus status;
}