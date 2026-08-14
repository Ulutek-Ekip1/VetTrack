package com.vettrack.api.clinic;

import com.vettrack.api.clinic.dto.ClinicMembershipResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class ClinicMembershipResponseTest {

    @Test
    @DisplayName("ClinicMembership entity'sinden ClinicMembershipResponse DTO'su doğru eşlenmeli")
    void testFromEntity() {
        UUID id = UUID.randomUUID();
        UUID userId = UUID.randomUUID();
        UUID clinicId = UUID.randomUUID();
        OffsetDateTime now = OffsetDateTime.now();

        ClinicMembership membership = ClinicMembership.builder()
                .id(id)
                .userId(userId)
                .clinicId(clinicId)
                .role("doctor")
                .isClinicAdmin(true)
                .status("active")
                .joinedAt(now)
                .createdAt(now)
                .updatedAt(now)
                .build();

        ClinicMembershipResponse response = ClinicMembershipResponse.fromEntity(membership);

        assertNotNull(response);
        assertEquals(id, response.getId());
        assertEquals(userId, response.getUserId());
        assertEquals(clinicId, response.getClinicId());
        assertEquals("doctor", response.getRole());
        assertTrue(response.getIsClinicAdmin());
        assertEquals("active", response.getStatus());
        assertEquals(now, response.getJoinedAt());
        assertEquals(now, response.getCreatedAt());
        assertEquals(now, response.getUpdatedAt());
    }

    @Test
    @DisplayName("null entity girildiğinde fromEntity null dönmeli")
    void testFromEntityNull() {
        assertNull(ClinicMembershipResponse.fromEntity(null));
    }
}
