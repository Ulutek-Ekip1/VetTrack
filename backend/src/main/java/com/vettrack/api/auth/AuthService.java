package com.vettrack.api.auth;

import com.vettrack.api.common.exception.ApiException;
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerRepository;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.clinic.ClinicMembershipService;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class AuthService {

    private final String supabaseUrl;
    private final String supabaseServiceKey;
    private final OwnerRepository ownerRepository;
    private final ClinicMembershipService clinicMembershipService;
    
    private final PetRepository petRepository;
    private final RestTemplate restTemplate;

    public AuthService(
            @Value("${supabase.url:${SUPABASE_URL:}}") String supabaseUrl,
            @Value("${supabase.service-key:${SUPABASE_SERVICE_KEY:}}") String supabaseServiceKey,
            OwnerRepository ownerRepository,
            RestTemplate restTemplate
    ) {
        this(supabaseUrl, supabaseServiceKey, ownerRepository, null, null, restTemplate);
    }

    @org.springframework.beans.factory.annotation.Autowired
    public AuthService(
            @Value("${supabase.url:${SUPABASE_URL:}}") String supabaseUrl,
            @Value("${supabase.service-key:${SUPABASE_SERVICE_KEY:}}") String supabaseServiceKey,
            OwnerRepository ownerRepository,
              ClinicMembershipService clinicMembershipService,
              PetRepository petRepository,
            RestTemplate restTemplate
    ) {
        this.supabaseUrl = supabaseUrl;
        this.supabaseServiceKey = supabaseServiceKey;
        this.ownerRepository = ownerRepository;
        this.clinicMembershipService = clinicMembershipService;
        this.petRepository = petRepository;
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
        userMetadata.put("role", request.getRole());
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

            return mapToAuthResponse(resp.getBody());
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            String responseBody = ex.getResponseBodyAsString();
            if (status.value() == HttpStatus.CONFLICT.value() || 
                status.value() == HttpStatus.UNPROCESSABLE_ENTITY.value() || 
                status.value() == 422 ||
                responseBody.contains("already_exists") || 
                responseBody.contains("already registered") ||
                responseBody.contains("user_already_exists")) {
                throw new ConflictException("EMAIL_ALREADY_EXISTS");
            } else if (status.value() == HttpStatus.BAD_REQUEST.value()) {
                throw new ConflictException("Invalid registration request");
            } else if (status.value() == HttpStatus.TOO_MANY_REQUESTS.value()) {
                throw new IllegalArgumentException("Supabase e-posta gönderim limiti aşıldı. Lütfen bir süre sonra tekrar deneyin.");
            } else {
                throw new RuntimeException("Registration failed: [" + status + "] " + responseBody, ex);
            }
        } catch (Exception ex) {
            throw new RuntimeException("Registration failed: " + ex.getMessage(), ex);
        }
    }

    public AuthResponse login(LoginRequest request) {
        String url = supabaseUrl + "/auth/v1/token?grant_type=password";

        HttpHeaders headers = createHeaders(MediaType.APPLICATION_JSON);

        Map<String, String> body = new HashMap<>();
        body.put("email", request.getEmail());
        body.put("password", request.getPassword());

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(
                    url, HttpMethod.POST, entity, new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            return mapToAuthResponse(resp.getBody());
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            if (status.value() == HttpStatus.UNAUTHORIZED.value() || status.value() == HttpStatus.BAD_REQUEST.value()) {
                String responseBody = ex.getResponseBodyAsString();
                if (responseBody.contains("Email not confirmed") || responseBody.contains("email_not_confirmed")) {
                    throw new UnauthorizedException("E-posta adresi doğrulanmamış. Lütfen gelen kutunuzu kontrol edin.");
                }
                throw new UnauthorizedException("E-posta veya şifre hatalı: " + responseBody);
            } else {
                throw new RuntimeException("Login failed");
            }
        } catch (Exception ex) {
            throw new RuntimeException("Login failed", ex);
        }
    }

    public void resendVerification(String email) {
        String url = supabaseUrl + "/auth/v1/resend";

        Map<String, Object> body = new HashMap<>();
        body.put("type", "signup");
        body.put("email", email);

        HttpHeaders headers = createHeaders(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            restTemplate.exchange(
                    url, HttpMethod.POST, entity, new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            log.info("Verification email resend requested for email hash={}", Integer.toHexString(email.hashCode()));
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            String responseBody = ex.getResponseBodyAsString();

            if (status.is4xxClientError()) {
                log.info("Supabase resend returned {} for email hash={} — treating as success (enumeration guard)",
                        status.value(), Integer.toHexString(email.hashCode()));
                return;
            }

            log.error("Supabase resend failed with status {}: {}", status.value(), responseBody);
            throw new RuntimeException("Verification email resend failed: [" + status + "] " + responseBody, ex);
        } catch (Exception ex) {
            log.error("Supabase resend failed: {}", ex.getMessage());
            throw new RuntimeException("Verification email resend failed: " + ex.getMessage(), ex);
        }
    }

    public void forgotPassword(String email) {
        String url = supabaseUrl + "/auth/v1/recover";

        Map<String, Object> body = new HashMap<>();
        body.put("email", email);

        HttpHeaders headers = createHeaders(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            restTemplate.exchange(
                    url, HttpMethod.POST, entity, new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            log.info("Password reset link requested for email hash={}", Integer.toHexString(email.hashCode()));
        } catch (HttpClientErrorException ex) {
            HttpStatusCode status = ex.getStatusCode();
            if (status.is4xxClientError()) {
                log.info("Supabase password recovery returned {} for email hash={} - treating as success (enumeration guard)",
                        status.value(), Integer.toHexString(email.hashCode()));
                return;
            }
            log.error("Supabase password recovery failed with status {}: {}", status.value(), ex.getResponseBodyAsString());
            throw new RuntimeException("Password recovery failed: " + ex.getMessage(), ex);
        } catch (Exception ex) {
            log.error("Supabase password recovery failed: {}", ex.getMessage());
            throw new RuntimeException("Password recovery failed: " + ex.getMessage(), ex);
        }
    }

    /**
     * Soft-deletes user profiles and all owned pets, while enforcing Supabase account ban (876600h).
     */
    @Transactional
    public void softDeleteUserAccount(UUID userId) {
        boolean found = false;

        Optional<Owner> ownerOpt = ownerRepository.findById(userId);
        if (ownerOpt.isPresent()) {
            Owner owner = ownerOpt.get();
            owner.setIsActive(false);
            owner.setUpdatedAt(OffsetDateTime.now());
            ownerRepository.save(owner);
            found = true;
            log.info("Soft-deleted owner profile in database for userId={}", userId);
        }

        

        if (clinicMembershipService != null) {
            clinicMembershipService.disableAllMemberships(userId);
            log.info("Disabled all clinic memberships for userId={}", userId);
        }

        // Soft-delete all pets owned by the user according to API contract specification
        if (petRepository != null) {
            List<Pet> pets = petRepository.findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(userId);
            for (Pet pet : pets) {
                pet.setIsActive(false);
                pet.setDeletedAt(OffsetDateTime.now());
                petRepository.save(pet);
            }
            log.info("Soft-deleted {} pets owned by userId={}", pets.size(), userId);
        }

        // Enforce account ban in Supabase Admin API so user cannot log back in or generate new tokens
        if (StringUtils.hasText(supabaseUrl) && StringUtils.hasText(supabaseServiceKey)) {
            String adminUrl = supabaseUrl + "/auth/v1/admin/users/" + userId;
            Map<String, Object> body = new HashMap<>();
            body.put("ban_duration", "876600h"); // Ban user for 100 years
            Map<String, Object> userMetadata = new HashMap<>();
            userMetadata.put("is_active", false);
            body.put("user_metadata", userMetadata);

            HttpHeaders headers = createHeaders(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            try {
                restTemplate.exchange(adminUrl, HttpMethod.PUT, entity, Map.class);
                log.info("Banned user in Supabase Auth and marked inactive for userId={}", userId);
            } catch (Exception e) {
                log.warn("Supabase Admin API user ban call failed for userId={}: {}", userId, e.getMessage());
            }
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








