package com.vettrack.api.clinic;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:clinicacceptdb;DB_CLOSE_DELAY=-1",
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
class ClinicControllerTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ClinicRepository clinicRepository;
    @Autowired
    private ClinicInviteRepository inviteRepository;
    @Autowired
    private ClinicMembershipRepository membershipRepository;

    private UUID clinicId;

    @BeforeEach
    void setUp() {
        membershipRepository.deleteAll();
        inviteRepository.deleteAll();
        clinicRepository.deleteAll();
        clinicId = clinicRepository.save(Clinic.builder().name("Test Kliniği").build()).getId();
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private void saveInvite(String rawToken, String email, OffsetDateTime acceptedAt) {
        inviteRepository.save(ClinicInvite.builder()
                .clinicId(clinicId)
                .email(email)
                .tokenHash(sha256(rawToken))
                .expiresAt(OffsetDateTime.now().plusDays(7))
                .acceptedAt(acceptedAt)
                .createdBy(UUID.randomUUID())
                .build());
    }

    @Test
    @DisplayName("Idempotency: zaten aktif üye (accepted invite retry) -> 200, hata değil")
    void acceptInvite_whenAlreadyActiveMember_returns200() throws Exception {
        UUID userId = UUID.randomUUID();
        membershipRepository.save(ClinicMembership.builder()
                .userId(userId).clinicId(clinicId).role("doctor")
                .isClinicAdmin(false).status("active").joinedAt(OffsetDateTime.now()).build());
        // retry senaryosu: davet ilk kabulde zaten accepted işaretlenmişti
        saveInvite("RAW-RETRY", null, OffsetDateTime.now());

        mockMvc.perform(post("/clinics/invites/accept")
                        .contentType(MediaType.APPLICATION_JSON).content("{\"token\":\"RAW-RETRY\"}")
                        .with(jwt().jwt(b -> b.subject(userId.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Klinik üyeliği zaten aktif."));
    }

    @Test
    @DisplayName("Happy path: yeni üye daveti kabul eder -> 200, üyelik oluşur, invite accepted olur")
    void acceptInvite_newMember_createsMembership() throws Exception {
        UUID userId = UUID.randomUUID();
        saveInvite("RAW-NEW", null, null); // email null -> e-posta eşleşme kontrolü atlanır

        mockMvc.perform(post("/clinics/invites/accept")
                        .contentType(MediaType.APPLICATION_JSON).content("{\"token\":\"RAW-NEW\"}")
                        .with(jwt().jwt(b -> b.subject(userId.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.clinic_id").value(clinicId.toString()));

        Optional<ClinicMembership> created = membershipRepository.findByUserIdAndClinicId(userId, clinicId);
        assertTrue(created.isPresent(), "Üyelik oluşturulmalı");
        assertEquals("active", created.get().getStatus());
        assertNotNull(inviteRepository.findByTokenHash(sha256("RAW-NEW")).orElseThrow().getAcceptedAt(),
                "Invite accepted_at işaretlenmeli");
    }

    @Test
    @DisplayName("Kullanılmış davet + üye DEĞİL -> 400 (idempotency yalnızca aktif üyeye özel)")
    void acceptInvite_usedInviteNonMember_returns400() throws Exception {
        UUID userId = UUID.randomUUID();
        saveInvite("RAW-USED2", null, OffsetDateTime.now()); // accepted, ama kullanıcı üye değil

        mockMvc.perform(post("/clinics/invites/accept")
                        .contentType(MediaType.APPLICATION_JSON).content("{\"token\":\"RAW-USED2\"}")
                        .with(jwt().jwt(b -> b.subject(userId.toString()))))
                .andExpect(status().isBadRequest());
    }
}
