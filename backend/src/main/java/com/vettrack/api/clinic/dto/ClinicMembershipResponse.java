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
