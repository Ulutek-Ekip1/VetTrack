package com.vettrack.api.clinic;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vettrack.api.clinic.dto.RegisterAndAcceptInviteRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * INT-FINDING-02 (P0, QA Test Raporu 19.08.2026) — POST /clinics/invites/register-and-accept
 * uçtan uca doğrulaması: hesap oluşturma ve klinik üyeliği tek istekte, gerçek oturum
 * tokenlarıyla birlikte tamamlanmalı; Supabase e-posta doğrulama ayarına bağımlı olmamalı.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:registeraccepttestdb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://test.supabase.co",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
@AutoConfigureMockMvc
class ClinicRegisterAndAcceptInviteTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ClinicRepository clinicRepository;
    @Autowired
    private ClinicInviteRepository inviteRepository;
    @Autowired
    private ClinicMembershipRepository membershipRepository;
    @MockitoBean
    private RestTemplate restTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private UUID clinicId;

    @BeforeEach
    void setUp() {
        membershipRepository.deleteAll();
        inviteRepository.deleteAll();
        clinicRepository.deleteAll();
        clinicId = clinicRepository.save(Clinic.builder().name("Kadıköy Veteriner Kliniği").build()).getId();
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private ClinicInvite saveInvite(String rawToken, String email, OffsetDateTime expiresAt) {
        return inviteRepository.save(ClinicInvite.builder()
                .clinicId(clinicId)
                .email(email)
                .tokenHash(sha256(rawToken))
                .expiresAt(expiresAt)
                .createdBy(UUID.randomUUID())
                .build());
    }

    @SuppressWarnings("unchecked")
    private void stubSupabaseCreateAndLogin(UUID createdUserId) {
        when(restTemplate.exchange(
                eq("https://test.supabase.co/auth/v1/admin/users"),
                eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(new ResponseEntity<>(Map.of("id", createdUserId.toString()), HttpStatus.OK));

        when(restTemplate.exchange(
                eq("https://test.supabase.co/auth/v1/token?grant_type=password"),
                eq(HttpMethod.POST), any(HttpEntity.class), any(ParameterizedTypeReference.class)
        )).thenReturn(new ResponseEntity<>(Map.of(
                "access_token", "real-session-token",
                "refresh_token", "real-refresh-token",
                "token_type", "bearer",
                "expires_in", 3600,
                "user", Map.of("id", createdUserId.toString(), "email", "vet@example.com")
        ), HttpStatus.OK));
    }

    @Test
    @DisplayName("Geçerli davet: hesap + klinik üyeliği tek istekte oluşur, gerçek oturum tokenı döner")
    void whenValidInvite_thenCreatesAccountAndMembershipAtomically() throws Exception {
        saveInvite("RAW-TOKEN-1", "vet@example.com", OffsetDateTime.now().plusDays(7));
        UUID createdUserId = UUID.randomUUID();
        stubSupabaseCreateAndLogin(createdUserId);

        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Dr. Vet");
        request.setEmail("vet@example.com");
        request.setPassword("sifre123");
        request.setToken("RAW-TOKEN-1");

        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.accessToken", is("real-session-token")))
                .andExpect(jsonPath("$.user", notNullValue()));

        var membership = membershipRepository.findByUserIdAndClinicId(createdUserId, clinicId);
        org.junit.jupiter.api.Assertions.assertTrue(membership.isPresent());
        org.junit.jupiter.api.Assertions.assertEquals("active", membership.get().getStatus());

        var invite = inviteRepository.findByTokenHash(sha256("RAW-TOKEN-1")).orElseThrow();
        org.junit.jupiter.api.Assertions.assertNotNull(invite.getAcceptedAt());
    }

    @Test
    @DisplayName("Kısmi önceki denemeden retry: üyelik zaten varsa (create+membership tamam, invite.acceptedAt yazımı önceden başarısız olmuş) mükerrer satır oluşmadan devam eder")
    void whenMembershipAlreadyExistsFromPartialPriorAttempt_thenDoesNotDuplicate() throws Exception {
        ClinicInvite invite = saveInvite("RAW-TOKEN-2", "vet2@example.com", OffsetDateTime.now().plusDays(7));
        UUID existingUserId = UUID.randomUUID();
        // Önceki (kısmi başarısız) denemeden kalan üyelik — invite.acceptedAt hâlâ null.
        membershipRepository.save(ClinicMembership.builder()
                .userId(existingUserId)
                .clinicId(clinicId)
                .role("doctor")
                .isClinicAdmin(false)
                .status("active")
                .joinedAt(OffsetDateTime.now())
                .build());

        stubSupabaseCreateAndLogin(existingUserId);

        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Dr. Vet İki");
        request.setEmail("vet2@example.com");
        request.setPassword("sifre123");
        request.setToken("RAW-TOKEN-2");

        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated());

        var memberships = membershipRepository.findByUserId(existingUserId);
        org.junit.jupiter.api.Assertions.assertEquals(1, memberships.size());

        var reloadedInvite = inviteRepository.findById(invite.getId()).orElseThrow();
        org.junit.jupiter.api.Assertions.assertNotNull(reloadedInvite.getAcceptedAt());
    }

    @Test
    @DisplayName("Süresi dolmuş davet: 400 döner, hesap oluşturulmaz")
    void whenInviteExpired_thenBadRequestAndNoAccountCreated() throws Exception {
        saveInvite("RAW-EXPIRED", "vet3@example.com", OffsetDateTime.now().minusDays(1));

        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Dr. Vet Üç");
        request.setEmail("vet3@example.com");
        request.setPassword("sifre123");
        request.setToken("RAW-EXPIRED");

        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        org.mockito.Mockito.verifyNoInteractions(restTemplate);
    }

    @Test
    @DisplayName("Farklı e-posta için oluşturulmuş davet: 403, hesap oluşturulmaz")
    void whenEmailMismatch_thenForbiddenAndNoAccountCreated() throws Exception {
        saveInvite("RAW-MISMATCH", "gercek-davetli@example.com", OffsetDateTime.now().plusDays(7));

        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Başkası");
        request.setEmail("baskasi@example.com");
        request.setPassword("sifre123");
        request.setToken("RAW-MISMATCH");

        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());

        org.mockito.Mockito.verifyNoInteractions(restTemplate);
    }

    @Test
    @DisplayName("Geçersiz token: 404 döner")
    void whenTokenInvalid_thenNotFound() throws Exception {
        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Kimse");
        request.setEmail("kimse@example.com");
        request.setPassword("sifre123");
        request.setToken("NONEXISTENT");

        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Endpoint public — JWT olmadan da erişilebilir (auth henüz kurulmadığı için)")
    void endpointIsPublic_doesNotRequireAuthentication() throws Exception {
        saveInvite("RAW-PUBLIC-CHECK", "public@example.com", OffsetDateTime.now().plusDays(7));
        UUID createdUserId = UUID.randomUUID();
        stubSupabaseCreateAndLogin(createdUserId);

        RegisterAndAcceptInviteRequest request = new RegisterAndAcceptInviteRequest();
        request.setName("Public Test");
        request.setEmail("public@example.com");
        request.setPassword("sifre123");
        request.setToken("RAW-PUBLIC-CHECK");

        // Not: .with(jwt()) KULLANILMIYOR — bilinçli olarak anonim istek.
        mockMvc.perform(post("/clinics/invites/register-and-accept")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated());
    }
}
