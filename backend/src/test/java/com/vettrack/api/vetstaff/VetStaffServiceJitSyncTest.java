package com.vettrack.api.vetstaff;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class VetStaffServiceJitSyncTest {

    private VetStaffRepository repository;
    private VetStaffService service;

    @BeforeEach
    void setUp() {
        repository = mock(VetStaffRepository.class);
        service = new VetStaffService(repository);
    }

    private Jwt jwtWith(Map<String, Object> userMetadata) {
        Map<String, Object> claims = userMetadata == null
                ? Map.of("sub", UUID.randomUUID().toString())
                : Map.of("sub", UUID.randomUUID().toString(), "user_metadata", userMetadata);
        return new Jwt("token", Instant.now(), Instant.now().plusSeconds(3600),
                Map.of("alg", "ES256"), claims);
    }

    @Test
    void shouldReturnExistingVetStaffWithoutCreating() {
        UUID userId = UUID.randomUUID();
        VetStaff existing = VetStaff.builder().userId(userId).staffRole("vet").build();
        when(repository.findByUserId(userId)).thenReturn(Optional.of(existing));

        VetStaff result = service.getOrCreateByUserId(userId, jwtWith(null));

        assertSame(existing, result);
        verify(repository, never()).save(any());
    }

    @Test
    void shouldCreateVetStaffOnFirstAccessWithDefaultRole() {
        UUID userId = UUID.randomUUID();
        when(repository.findByUserId(userId)).thenReturn(Optional.empty());
        when(repository.save(any(VetStaff.class))).thenAnswer(inv -> inv.getArgument(0));

        VetStaff result = service.getOrCreateByUserId(userId, jwtWith(null));

        assertEquals(userId, result.getUserId());
        assertEquals("doctor", result.getStaffRole());
        assertTrue(result.getIsActive());
    }

    @Test
    void shouldUseStaffRoleFromJwtMetadataWhenPresent() {
        UUID userId = UUID.randomUUID();
        when(repository.findByUserId(userId)).thenReturn(Optional.empty());
        when(repository.save(any(VetStaff.class))).thenAnswer(inv -> inv.getArgument(0));

        Jwt jwt = jwtWith(Map.of("staff_role", "receptionist"));
        VetStaff result = service.getOrCreateByUserId(userId, jwt);

        assertEquals("receptionist", result.getStaffRole());
    }

    @Test
    void shouldRecoverFromConcurrentInsertRace() {
        // Race scenario: findByUserId returns empty (row not there yet),
        // save fails with UNIQUE(user_id) violation because another request just inserted,
        // second findByUserId returns the row that the winning request created.
        UUID userId = UUID.randomUUID();
        VetStaff winner = VetStaff.builder().userId(userId).staffRole("vet").build();

        when(repository.findByUserId(userId))
                .thenReturn(Optional.empty())   // first check: nothing there
                .thenReturn(Optional.of(winner)); // after save failure: row exists

        when(repository.save(any(VetStaff.class)))
                .thenThrow(new DataIntegrityViolationException("unique violation"));

        VetStaff result = service.getOrCreateByUserId(userId, jwtWith(null));

        assertSame(winner, result);
        verify(repository, times(2)).findByUserId(userId);
    }

    @Test
    void shouldPropagateRaceWhenRowStillMissingAfterConflict() {
        // Defensive: if save fails but a follow-up read also finds nothing, propagate.
        UUID userId = UUID.randomUUID();
        when(repository.findByUserId(userId)).thenReturn(Optional.empty());
        when(repository.save(any(VetStaff.class)))
                .thenThrow(new DataIntegrityViolationException("unique violation"));

        assertThrows(DataIntegrityViolationException.class,
                () -> service.getOrCreateByUserId(userId, jwtWith(null)));
    }
}
