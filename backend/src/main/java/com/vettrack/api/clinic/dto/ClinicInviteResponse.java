package com.vettrack.api.clinic.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClinicInviteResponse {
    private String message;
    private String inviteToken;
    private OffsetDateTime expiresAt;
    private UUID clinicId;

    @JsonProperty("invite_token")
    public String getInviteTokenSnake() {
        return inviteToken;
    }

    @JsonProperty("expires_at")
    public String getExpiresAtSnake() {
        return expiresAt != null ? expiresAt.toString() : null;
    }

    @JsonProperty("clinic_id")
    public UUID getClinicIdSnake() {
        return clinicId;
    }
}

