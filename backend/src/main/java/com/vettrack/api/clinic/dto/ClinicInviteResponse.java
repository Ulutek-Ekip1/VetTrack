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

    public static ClinicInviteResponseBuilder builder() {
        return new ClinicInviteResponseBuilder();
    }

    public static class ClinicInviteResponseBuilder {
        private String message;
        private String inviteToken;
        private OffsetDateTime expiresAt;
        private UUID clinicId;

        public ClinicInviteResponseBuilder message(String message) { this.message = message; return this; }
        public ClinicInviteResponseBuilder inviteToken(String inviteToken) { this.inviteToken = inviteToken; return this; }
        public ClinicInviteResponseBuilder expiresAt(OffsetDateTime expiresAt) { this.expiresAt = expiresAt; return this; }
        public ClinicInviteResponseBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }

        public ClinicInviteResponse build() {
            ClinicInviteResponse r = new ClinicInviteResponse();
            r.message = this.message;
            r.inviteToken = this.inviteToken;
            r.expiresAt = this.expiresAt;
            r.clinicId = this.clinicId;
            return r;
        }
    }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getInviteToken() { return inviteToken; }
    public void setInviteToken(String inviteToken) { this.inviteToken = inviteToken; }
    public OffsetDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(OffsetDateTime expiresAt) { this.expiresAt = expiresAt; }
    public UUID getClinicId() { return clinicId; }
    public void setClinicId(UUID clinicId) { this.clinicId = clinicId; }
}
