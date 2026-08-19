package com.vettrack.api.auth;

import com.vettrack.api.owner.OwnerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * INT-FINDING-02 (P0, QA Test Raporu 19.08.2026) — register + authenticated accept iki adımlı
 * akışının aksine, {@link AuthService#createConfirmedUserAndLogin} Supabase Admin API ile
 * e-postası önceden onaylanmış bir kullanıcı oluşturup gerçek bir oturum döner; Dashboard'daki
 * e-posta doğrulama ayarına bağımlı değildir.
 */
class AuthServiceCreateConfirmedUserTest {

    private RestTemplate restTemplate;
    private AuthService authService;

    private static final String SUPABASE_URL = "https://test.supabase.co";
    private static final String SERVICE_KEY = "test-service-key";

    @BeforeEach
    void setUp() {
        restTemplate = mock(RestTemplate.class);
        OwnerRepository ownerRepository = mock(OwnerRepository.class);
        authService = new AuthService(SUPABASE_URL, SERVICE_KEY, ownerRepository, restTemplate);
    }

    private ResponseEntity<Map<String, Object>> loginResponse() {
        UUID userId = UUID.randomUUID();
        Map<String, Object> body = Map.of(
                "access_token", "real-session-token",
                "refresh_token", "real-refresh-token",
                "token_type", "bearer",
                "expires_in", 3600,
                "user", Map.of("id", userId.toString(), "email", "vet@example.com")
        );
        return new ResponseEntity<>(body, HttpStatus.OK);
    }

    @Test
    void whenCreateSucceeds_thenLogsInAndReturnsRealSessionTokens() {
        when(restTemplate.exchange(
                eq(SUPABASE_URL + "/auth/v1/admin/users"), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(new ResponseEntity<>(Map.of("id", UUID.randomUUID().toString()), HttpStatus.OK));

        when(restTemplate.exchange(
                eq(SUPABASE_URL + "/auth/v1/token?grant_type=password"), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(loginResponse());

        AuthResponse response = authService.createConfirmedUserAndLogin(
                "vet@example.com", "sifre123", "Dr. Vet", null);

        assertEquals("real-session-token", response.getAccessToken());
        assertNotNull(response.getUser());

        verify(restTemplate).exchange(
                eq(SUPABASE_URL + "/auth/v1/admin/users"),
                eq(HttpMethod.POST),
                argThat((HttpEntity<Map<String, Object>> entity) -> {
                    Map<String, Object> body = entity.getBody();
                    if (body == null) return false;
                    Boolean emailConfirm = (Boolean) body.get("email_confirm");
                    return Boolean.TRUE.equals(emailConfirm) && "vet@example.com".equals(body.get("email"));
                }),
                any(ParameterizedTypeReference.class)
        );
    }

    @Test
    void whenUserAlreadyExists_thenFallsBackToLoginInsteadOfFailing() {
        when(restTemplate.exchange(
                eq(SUPABASE_URL + "/auth/v1/admin/users"), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenThrow(HttpClientErrorException.create(
                HttpStatus.UNPROCESSABLE_ENTITY, "user_already_exists", HttpHeaders.EMPTY,
                "{\"error\":\"user_already_exists\"}".getBytes(), null));

        when(restTemplate.exchange(
                eq(SUPABASE_URL + "/auth/v1/token?grant_type=password"), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(loginResponse());

        // Kısmi önceki denemeden retry — kullanıcı zaten var ama üyelik yazımı başarısız olmuştu.
        AuthResponse response = authService.createConfirmedUserAndLogin(
                "vet@example.com", "sifre123", "Dr. Vet", null);

        assertEquals("real-session-token", response.getAccessToken());
    }

    @Test
    void whenCreateFailsForOtherReason_thenThrowsAndDoesNotAttemptLogin() {
        when(restTemplate.exchange(
                eq(SUPABASE_URL + "/auth/v1/admin/users"), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenThrow(HttpClientErrorException.create(
                HttpStatus.INTERNAL_SERVER_ERROR, "supabase down", HttpHeaders.EMPTY, new byte[0], null));

        assertThrows(RuntimeException.class, () ->
                authService.createConfirmedUserAndLogin("vet@example.com", "sifre123", "Dr. Vet", null));

        verify(restTemplate, never()).exchange(
                eq(SUPABASE_URL + "/auth/v1/token?grant_type=password"), any(HttpMethod.class), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        );
    }
}
