package com.vettrack.api.auth;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;

import com.vettrack.api.clinic.ClinicMembershipService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class AuthControllerMeTest {

    private AuthService authService;
    private OwnerService ownerService;
    private ClinicMembershipService clinicMembershipService;
    private AuthController controller;

    @BeforeEach
    void setUp() {
        authService = mock(AuthService.class);
        ownerService = mock(OwnerService.class);
        clinicMembershipService = mock(ClinicMembershipService.class);
        controller = new AuthController(authService, ownerService, clinicMembershipService);
        when(clinicMembershipService.getMembershipsByUser(any())).thenReturn(java.util.List.of());
    }

    private Jwt jwtWith(UUID sub, String email, Map<String, Object> userMetadata, String topLevelRole) {
        var claims = new java.util.HashMap<String, Object>();
        claims.put("sub", sub.toString());
        if (email != null) claims.put("email", email);
        if (userMetadata != null) claims.put("user_metadata", userMetadata);
        if (topLevelRole != null) claims.put("role", topLevelRole);
        return new Jwt("token", Instant.now(), Instant.now().plusSeconds(3600),
                Map.of("alg", "ES256"), claims);
    }

    @Test
    void shouldReturn401WhenJwtIsNull() {
        ResponseEntity<Map<String, Object>> response = controller.me(null);
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        verifyNoInteractions(ownerService);
    }

    @Test
    void shouldRouteToOwnerServiceWhenRoleIsOwner() {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder().id(userId).email("owner@test.com").fullName("Test Owner").role("owner").build();
        when(ownerService.getOwnerById(userId)).thenReturn(owner);

        Jwt jwt = jwtWith(userId, "owner@test.com", Map.of("role", "owner"), "authenticated");
        ResponseEntity<Map<String, Object>> response = controller.me(jwt);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        assertNotNull(body);
        assertEquals(userId.toString(), body.get("id"));
        assertEquals("owner@test.com", body.get("email"));
        assertEquals("owner", body.get("role"));
        assertSame(owner, body.get("profile"));
        verify(ownerService).getOwnerById(userId);
    }

    @Test
    void shouldReturnOwnerWhenRoleIsVetStaff() {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder().id(userId).email("vet@test.com").fullName("Test Vet").role("vet_staff").build();
        when(ownerService.getOwnerById(userId)).thenReturn(owner);

        Jwt jwt = jwtWith(userId, "vet@test.com", Map.of("role", "vet_staff"), "authenticated");
        ResponseEntity<Map<String, Object>> response = controller.me(jwt);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        assertNotNull(body);
        assertEquals("vet_staff", body.get("role"));
        assertSame(owner, body.get("profile"));
        verify(ownerService).getOwnerById(userId);
    }

    @Test
    void shouldFallBackToOwnerWhenRoleClaimMissingEntirely() {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder().id(userId).email("legacy@test.com").fullName("Legacy").role("owner").build();
        when(ownerService.getOwnerById(userId)).thenReturn(owner);

        Jwt jwt = jwtWith(userId, "legacy@test.com", null, null);
        ResponseEntity<Map<String, Object>> response = controller.me(jwt);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("owner", response.getBody().get("role"));
        verify(ownerService).getOwnerById(userId);
    }
}
