package com.vettrack.api.auth;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class AuthService {

    private final String supabaseUrl;
    private final String supabaseServiceKey;
    private final OwnerRepository ownerRepository;
    private final RestTemplate restTemplate;

    public AuthService(
            @Value("${SUPABASE_URL}") String supabaseUrl,
            @Value("${SUPABASE_SERVICE_KEY}") String supabaseServiceKey,
            OwnerRepository ownerRepository,
            RestTemplate restTemplate
    ) {
        this.supabaseUrl = supabaseUrl;
        this.supabaseServiceKey = supabaseServiceKey;
        this.ownerRepository = ownerRepository;
        this.restTemplate = restTemplate;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String url = supabaseUrl + "/auth/v1/signup";

        Map<String, Object> body = new HashMap<>();
        body.put("email", request.getEmail());
        body.put("password", request.getPassword());

        Map<String, Object> userMetadata = new HashMap<>();
        userMetadata.put("name", request.getName());
        if (request.getPhone() != null) {
            userMetadata.put("phone", request.getPhone());
        }
        body.put("data", userMetadata);

        HttpHeaders headers = createHeaders(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(
                    url, HttpMethod.POST, entity, new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            AuthResponse authResponse = mapToAuthResponse(resp.getBody());

            if (request.getEmail() != null && authResponse != null && authResponse.getUser() instanceof Map) {
                @SuppressWarnings("unchecked")
                Map<String, Object> userMap = (Map<String, Object>) authResponse.getUser();
                String supabaseUserIdStr = (String) userMap.get("id");
                
                if (supabaseUserIdStr != null) {
                    UUID supabaseUserId = UUID.fromString(supabaseUserIdStr);
                    saveOwnerIfNotExist(supabaseUserId, request.getEmail(), request.getName(), request.getPhone());
                }
            }

            return authResponse;
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            if (status.value() == HttpStatus.CONFLICT.value()) {
                throw new ConflictException("EMAIL_ALREADY_EXISTS");
            } else if (status.value() == HttpStatus.BAD_REQUEST.value()) {
                String responseBody = ex.getResponseBodyAsString();
                if (responseBody.contains("already_exists") || responseBody.contains("already registered")) {
                    throw new ConflictException("EMAIL_ALREADY_EXISTS");
                }
                throw new ConflictException("Invalid registration request");
            } else {
                throw new RuntimeException("Registration failed");
            }
        } catch (Exception ex) {
            throw new RuntimeException("Registration failed", ex);
        }
    }

    private void saveOwnerIfNotExist(UUID id, String email, String name, String phone) {
        if (ownerRepository.findByEmail(email).isEmpty()) {
            Owner owner = Owner.builder()
                    .id(id)
                    .email(email)
                    .name(name)
                    .phone(phone)
                    .build();
            ownerRepository.save(owner);
        }
    }

    public AuthResponse login(LoginRequest request) {
        String url = supabaseUrl + "/auth/v1/token?grant_type=password";

        HttpHeaders headers = createHeaders(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add("email", request.getEmail());
        formData.add("password", request.getPassword());

        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(formData, headers);

        try {
            ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(
                    url, HttpMethod.POST, entity, new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            return mapToAuthResponse(resp.getBody());
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            if (status.value() == HttpStatus.UNAUTHORIZED.value() || status.value() == HttpStatus.BAD_REQUEST.value()) {
                throw new UnauthorizedException("E-posta veya şifre hatalı");
            } else {
                throw new RuntimeException("Login failed");
            }
        } catch (Exception ex) {
            throw new RuntimeException("Login failed", ex);
        }
    }

    private HttpHeaders createHeaders(MediaType mediaType) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(mediaType);
        headers.set("apikey", supabaseServiceKey);
        headers.set("Authorization", "Bearer " + supabaseServiceKey);
        return headers;
    }

    private AuthResponse mapToAuthResponse(Map<String, Object> respBody) {
        if (respBody == null) return null;

        Object expires = respBody.get("expires_in");
        Integer expiresIn = (expires instanceof Number) ? ((Number) expires).intValue() : null;

        return AuthResponse.builder()
                .accessToken((String) respBody.get("access_token"))
                .refreshToken((String) respBody.get("refresh_token"))
                .tokenType((String) respBody.get("token_type"))
                .expiresIn(expiresIn)
                .user(respBody.get("user"))
                .build();
    }
}