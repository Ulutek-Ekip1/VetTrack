package com.vettrack.api.auth;

import com.vettrack.api.owner.OwnerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthServiceResendVerificationTest {

    private RestTemplate restTemplate;
    private OwnerRepository ownerRepository;
    private AuthService authService;

    private static final String SUPABASE_URL = "https://test.supabase.co";
    private static final String SERVICE_KEY = "test-service-key";

    @BeforeEach
    void setUp() {
        restTemplate = mock(RestTemplate.class);
        ownerRepository = mock(OwnerRepository.class);
        authService = new AuthService(SUPABASE_URL, SERVICE_KEY, ownerRepository, restTemplate);
    }

    @Test
    void shouldCallSupabaseResendEndpointWithSignupType() {
        when(restTemplate.exchange(
                anyString(), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(new ResponseEntity<>(Map.of(), HttpStatus.OK));

        authService.resendVerification("user@example.com");

        verify(restTemplate).exchange(
                eq(SUPABASE_URL + "/auth/v1/resend"),
                eq(HttpMethod.POST),
                argThat((HttpEntity<Map<String, Object>> entity) -> {
                    Map<String, Object> body = entity.getBody();
                    return body != null
                            && "signup".equals(body.get("type"))
                            && "user@example.com".equals(body.get("email"))
                            && SERVICE_KEY.equals(entity.getHeaders().getFirst("apikey"));
                }),
                any(ParameterizedTypeReference.class)
        );
    }

    @Test
    void shouldSwallow4xxToPreventEnumeration() {
        // Supabase returns 400 for unknown email or 422 for already-confirmed.
        when(restTemplate.exchange(
                anyString(), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenThrow(HttpClientErrorException.create(
                HttpStatus.UNPROCESSABLE_ENTITY, "user already confirmed", HttpHeaders.EMPTY, new byte[0], null
        ));

        // Should NOT throw — enumeration guard.
        assertDoesNotThrow(() -> authService.resendVerification("existing@example.com"));
    }

    @Test
    void shouldSwallow400ForUnknownEmail() {
        when(restTemplate.exchange(
                anyString(), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenThrow(HttpClientErrorException.create(
                HttpStatus.BAD_REQUEST, "user not found", HttpHeaders.EMPTY, new byte[0], null
        ));

        assertDoesNotThrow(() -> authService.resendVerification("unknown@example.com"));
    }

    @Test
    void shouldPropagate5xxAsRuntimeException() {
        // Supabase infrastructure failure — the user should be able to retry.
        when(restTemplate.exchange(
                anyString(), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenThrow(HttpServerErrorException.create(
                HttpStatus.INTERNAL_SERVER_ERROR, "supabase down", HttpHeaders.EMPTY, new byte[0], null
        ));

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> authService.resendVerification("user@example.com"));
        assertTrue(ex.getMessage().contains("resend failed"));
    }

    @Test
    void shouldAppendRedirectToWhenEmailRedirectConfigured() {
        ReflectionTestUtils.setField(authService, "emailRedirectUrl", "vettrack://login-callback/");
        when(restTemplate.exchange(
                anyString(), eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(new ResponseEntity<>(Map.of(), HttpStatus.OK));

        authService.resendVerification("user@example.com");

        verify(restTemplate).exchange(
                argThat((String url) -> url != null
                        && url.startsWith(SUPABASE_URL + "/auth/v1/resend")
                        && url.contains("redirect_to=")
                        && url.contains("login-callback")),
                eq(HttpMethod.POST),
                any(HttpEntity.class),
                any(ParameterizedTypeReference.class)
        );
    }
}
