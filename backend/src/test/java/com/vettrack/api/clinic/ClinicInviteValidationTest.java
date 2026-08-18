package com.vettrack.api.clinic;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:clinicvalidatedb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
@AutoConfigureMockMvc
class ClinicInviteValidationTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ClinicRepository clinicRepository;
    @Autowired
    private ClinicInviteRepository inviteRepository;

    private UUID clinicId;
    private static final String CLINIC_NAME = "Kadıköy Veteriner Kliniği";

    @BeforeEach
    void setUp() {
        inviteRepository.deleteAll();
        clinicRepository.deleteAll();
        clinicId = clinicRepository.save(Clinic.builder().name(CLINIC_NAME).build()).getId();
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private void saveInvite(String rawToken, OffsetDateTime expiresAt, OffsetDateTime acceptedAt, OffsetDateTime revokedAt) {
        inviteRepository.save(ClinicInvite.builder()
                .clinicId(clinicId)
                .email("vet@example.com") // gizli kalmalı
                .tokenHash(sha256(rawToken))
                .expiresAt(expiresAt)
                .acceptedAt(acceptedAt)
                .revokedAt(revokedAt)
                .createdBy(UUID.randomUUID())
                .build());
    }

    @Test
    @DisplayName("Geçerli davet: 200 + valid/clinicId/clinicName, e-posta ifşa edilmez (public, JWT'siz)")
    void validInvite_returns200_withoutEmail() throws Exception {
        saveInvite("RAW-VALID", OffsetDateTime.now().plusDays(7), null, null);

        mockMvc.perform(get("/clinics/invites/validate").param("token", "RAW-VALID"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid").value(true))
                .andExpect(jsonPath("$.clinicId").value(clinicId.toString()))
                .andExpect(jsonPath("$.clinicName").value(CLINIC_NAME))
                .andExpect(jsonPath("$.email").doesNotExist());
    }

    @Test
    @DisplayName("Bilinmeyen kod: 404 Geçersiz davet kodu")
    void unknownToken_returns404() throws Exception {
        mockMvc.perform(get("/clinics/invites/validate").param("token", "NONEXISTENT"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Geçersiz davet kodu."));
    }

    @Test
    @DisplayName("Kullanılmış kod (accepted_at dolu): 409")
    void acceptedToken_returns409() throws Exception {
        saveInvite("RAW-USED", OffsetDateTime.now().plusDays(7), OffsetDateTime.now(), null);

        mockMvc.perform(get("/clinics/invites/validate").param("token", "RAW-USED"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("Bu davet kodu daha önce kullanılmış."));
    }

    @Test
    @DisplayName("İptal edilmiş kod (revoked_at dolu): 400")
    void revokedToken_returns400() throws Exception {
        saveInvite("RAW-REVOKED", OffsetDateTime.now().plusDays(7), null, OffsetDateTime.now());

        mockMvc.perform(get("/clinics/invites/validate").param("token", "RAW-REVOKED"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Bu davet iptal edilmiş."));
    }

    @Test
    @DisplayName("Süresi dolmuş kod (expires_at geçmiş): 410 Gone")
    void expiredToken_returns410() throws Exception {
        saveInvite("RAW-EXPIRED", OffsetDateTime.now().minusDays(1), null, null);

        mockMvc.perform(get("/clinics/invites/validate").param("token", "RAW-EXPIRED"))
                .andExpect(status().isGone())
                .andExpect(jsonPath("$.message").value("Bu davet kodunun süresi dolmuş."));
    }
}
