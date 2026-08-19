package com.vettrack.api.auth;

import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.owner.OwnerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

/**
 * QA Bulgu BE-FINDING-02: Supabase raw JSON error body client'a sızmamalı.
 */
@ExtendWith(MockitoExtension.class)
class AuthServiceLoginTest {

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private OwnerRepository ownerRepository;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(
                "http://localhost:54321",
                "test-service-key",
                ownerRepository,
                restTemplate
        );
    }

    @Test
    @SuppressWarnings("unchecked")
    @DisplayName("Hatalı girişte Supabase raw JSON hata gövdesi exception mesajına sızmamalı, temiz mesaj dönmeli")
    void whenLoginFailsWithInvalidCredentials_thenThrowsUnauthorizedExceptionWithCleanMessage() {
        String rawSupabaseJson = "{\"error\":\"invalid_grant\",\"error_description\":\"Invalid login credentials\"}";
        HttpClientErrorException clientError = HttpClientErrorException.create(
                HttpStatus.BAD_REQUEST,
                "Bad Request",
                HttpHeaders.EMPTY,
                rawSupabaseJson.getBytes(StandardCharsets.UTF_8),
                StandardCharsets.UTF_8
        );

        when(restTemplate.exchange(
                any(String.class),
                eq(HttpMethod.POST),
                any(),
                any(ParameterizedTypeReference.class)
        )).thenThrow(clientError);

        LoginRequest request = new LoginRequest();
        request.setEmail("test@example.com");
        request.setPassword("wrongpassword");

        UnauthorizedException exception = assertThrows(
                UnauthorizedException.class,
                () -> authService.login(request)
        );

        // 1. Kullanıcıya standart Türkçe mesaj dönmeli
        assertEquals("E-posta veya şifre hatalı", exception.getMessage());

        // 2. Ham Supabase JSON detayı kesinlikle mesajda yer almamalı (BE-FINDING-02)
        assertFalse(exception.getMessage().contains("invalid_grant"));
        assertFalse(exception.getMessage().contains("Invalid login credentials"));
    }

    @Test
    @SuppressWarnings("unchecked")
    @DisplayName("E-posta doğrulanmamışsa özel doğrulama uyarısı mesajı dönmeli")
    void whenEmailNotConfirmed_thenThrowsUnauthorizedExceptionWithEmailNotConfirmedMessage() {
        String rawSupabaseJson = "{\"error\":\"email_not_confirmed\",\"error_description\":\"Email not confirmed\"}";
        HttpClientErrorException clientError = HttpClientErrorException.create(
                HttpStatus.BAD_REQUEST,
                "Bad Request",
                HttpHeaders.EMPTY,
                rawSupabaseJson.getBytes(StandardCharsets.UTF_8),
                StandardCharsets.UTF_8
        );

        when(restTemplate.exchange(
                any(String.class),
                eq(HttpMethod.POST),
                any(),
                any(ParameterizedTypeReference.class)
        )).thenThrow(clientError);

        LoginRequest request = new LoginRequest();
        request.setEmail("unverified@example.com");
        request.setPassword("password123");

        UnauthorizedException exception = assertThrows(
                UnauthorizedException.class,
                () -> authService.login(request)
        );

        assertEquals("E-posta adresi doğrulanmamış. Lütfen gelen kutunuzu kontrol edin.", exception.getMessage());
    }
}