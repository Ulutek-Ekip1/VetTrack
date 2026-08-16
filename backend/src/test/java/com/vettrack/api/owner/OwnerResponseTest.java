package com.vettrack.api.owner;

import com.vettrack.api.owner.dto.OwnerResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class OwnerResponseTest {

    @Test
    @DisplayName("Owner entity'sinden OwnerResponse üretildiğinde tüm genel alanlar doğru aktarılmalı ve role/isActive sızdırılmamalı")
    void shouldMapOwnerEntityToOwnerResponseCorrectly() {
        UUID id = UUID.randomUUID();
        OffsetDateTime now = OffsetDateTime.now();

        Owner owner = Owner.builder()
                .id(id)
                .fullName("John Doe")
                .email("john@example.com")
                .phone("+905551112233")
                .role("owner")
                .isActive(true)
                .createdAt(now)
                .updatedAt(now)
                .build();

        OwnerResponse response = OwnerResponse.fromEntity(owner);

        assertNotNull(response);
        assertEquals(id, response.getId());
        assertEquals("John Doe", response.getFullName());
        assertEquals("john@example.com", response.getEmail());
        assertEquals("+905551112233", response.getPhone());
        assertEquals(now, response.getCreatedAt());
        assertEquals(now, response.getUpdatedAt());
    }

    @Test
    @DisplayName("null Owner entity verildiğinde null dönmeli")
    void shouldReturnNullWhenOwnerIsNull() {
        assertNull(OwnerResponse.fromEntity(null));
    }
}
