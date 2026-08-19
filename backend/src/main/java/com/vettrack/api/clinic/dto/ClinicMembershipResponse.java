package com.vettrack.api.clinic.dto;

import com.vettrack.api.clinic.ClinicMembership;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClinicMembershipResponse {
    private UUID id;
    private UUID userId;
    private UUID clinicId;
    private String role;
    private Boolean isClinicAdmin;
    private String status;
    private OffsetDateTime joinedAt;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public static ClinicMembershipResponseBuilder builder() {
        return new ClinicMembershipResponseBuilder();
    }

    public static class ClinicMembershipResponseBuilder {
        private UUID id;
        private UUID userId;
        private UUID clinicId;
        private String role;
        private Boolean isClinicAdmin;
        private String status;
        private OffsetDateTime joinedAt;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public ClinicMembershipResponseBuilder id(UUID id) { this.id = id; return this; }
        public ClinicMembershipResponseBuilder userId(UUID userId) { this.userId = userId; return this; }
        public ClinicMembershipResponseBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
        public ClinicMembershipResponseBuilder role(String role) { this.role = role; return this; }
        public ClinicMembershipResponseBuilder isClinicAdmin(Boolean isClinicAdmin) { this.isClinicAdmin = isClinicAdmin; return this; }
        public ClinicMembershipResponseBuilder status(String status) { this.status = status; return this; }
        public ClinicMembershipResponseBuilder joinedAt(OffsetDateTime joinedAt) { this.joinedAt = joinedAt; return this; }
        public ClinicMembershipResponseBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public ClinicMembershipResponseBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public ClinicMembershipResponse build() {
            ClinicMembershipResponse r = new ClinicMembershipResponse();
            r.id = this.id;
            r.userId = this.userId;
            r.clinicId = this.clinicId;
            r.role = this.role;
            r.isClinicAdmin = this.isClinicAdmin;
            r.status = this.status;
            r.joinedAt = this.joinedAt;
            r.createdAt = this.createdAt;
            r.updatedAt = this.updatedAt;
            return r;
        }
    }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public UUID getClinicId() { return clinicId; }
    public String getRole() { return role; }
    public Boolean getIsClinicAdmin() { return isClinicAdmin; }
    public String getStatus() { return status; }
    public OffsetDateTime getJoinedAt() { return joinedAt; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }

    public static ClinicMembershipResponse fromEntity(ClinicMembership entity) {
        if (entity == null) {
            return null;
        }
        return ClinicMembershipResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .clinicId(entity.getClinicId())
                .role(entity.getRole())
                .isClinicAdmin(entity.getIsClinicAdmin())
                .status(entity.getStatus())
                .joinedAt(entity.getJoinedAt())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
