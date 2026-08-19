package com.vettrack.api.contract;

import com.vettrack.api.clinic.Clinic;
import com.vettrack.api.clinic.ClinicInvite;
import com.vettrack.api.clinic.ClinicInviteRepository;
import com.vettrack.api.clinic.ClinicMembership;
import com.vettrack.api.clinic.ClinicMembershipRepository;
import com.vettrack.api.clinic.ClinicRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.visit.VisitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:authvsforbiddendb;DB_CLOSE_DELAY=-1",
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
class AuthVsForbiddenContractTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ClinicRepository clinicRepository;
    @Autowired
    private ClinicInviteRepository inviteRepository;
    @Autowired
    private ClinicMembershipRepository membershipRepository;
    @Autowired
    private PetRepository petRepository;
    @Autowired
    private PetService petService;
    @Autowired
    private VisitRepository visitRepository;

    private UUID clinicId;
    private Pet pet;

    @BeforeEach
    void setUp() {
        visitRepository.deleteAll();
        membershipRepository.deleteAll();
        inviteRepository.deleteAll();
        petRepository.deleteAll();
        clinicRepository.deleteAll();

        clinicId = clinicRepository.save(Clinic.builder().name("Merkez Veteriner").build()).getId();

        pet = petService.createPet(Pet.builder()
                .ownerId(UUID.randomUUID())
                .name("Karakız")
                .species("Kedi")
                .gender(Gender.female)
                .build());
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    @Nested
    @DisplayName("401 Unauthorized - Unauthenticated (Token Yok/Geçersiz)")
    class UnauthenticatedTests {

        @Test
        @DisplayName("POST /clinics/{id}/invites - Token yoksa 401 döner")
        void createInvite_unauthenticated_returns401() throws Exception {
            mockMvc.perform(post("/clinics/" + clinicId + "/invites")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"email\":\"hekim@example.com\"}"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("DELETE /clinics/{id}/invites/{inviteId} - Token yoksa 401 döner")
        void revokeInvite_unauthenticated_returns401() throws Exception {
            mockMvc.perform(delete("/clinics/" + clinicId + "/invites/" + UUID.randomUUID()))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("PATCH /clinics/{id}/members/{userId}/disable - Token yoksa 401 döner")
        void disableMember_unauthenticated_returns401() throws Exception {
            mockMvc.perform(patch("/clinics/" + clinicId + "/members/" + UUID.randomUUID() + "/disable"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("GET /visits/code/{code} - Token yoksa 401 döner")
        void getPatientByCode_unauthenticated_returns401() throws Exception {
            mockMvc.perform(get("/visits/code/" + pet.getUniqueCode()))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("POST /visits - Token yoksa 401 döner")
        void createVisit_unauthenticated_returns401() throws Exception {
            mockMvc.perform(post("/visits")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"petId\":\"" + pet.getId() + "\",\"chiefComplaint\":\"Kontrol\"}"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("403 Forbidden - Authenticated ama Yetkisiz (No Membership / Non-Admin / Mismatched)")
    class ForbiddenAuthorizationTests {

        @Test
        @DisplayName("POST /clinics/{id}/invites - Authenticated normal üye (clinic_admin değil) -> 403 Forbidden")
        void createInvite_authenticatedNonAdmin_returns403() throws Exception {
            UUID doctorId = UUID.randomUUID();
            membershipRepository.save(ClinicMembership.builder()
                    .userId(doctorId)
                    .clinicId(clinicId)
                    .role("doctor")
                    .isClinicAdmin(false)
                    .status("active")
                    .joinedAt(OffsetDateTime.now())
                    .build());

            mockMvc.perform(post("/clinics/" + clinicId + "/invites")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"email\":\"hekim@example.com\"}")
                            .with(jwt().jwt(j -> j.subject(doctorId.toString()))
                                    .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Bu işlem için bu klinikte clinic_admin olmalısınız."));
        }

        @Test
        @DisplayName("DELETE /clinics/{id}/invites/{inviteId} - Authenticated normal üye (clinic_admin değil) -> 403 Forbidden")
        void revokeInvite_authenticatedNonAdmin_returns403() throws Exception {
            UUID doctorId = UUID.randomUUID();
            membershipRepository.save(ClinicMembership.builder()
                    .userId(doctorId)
                    .clinicId(clinicId)
                    .role("doctor")
                    .isClinicAdmin(false)
                    .status("active")
                    .joinedAt(OffsetDateTime.now())
                    .build());

            ClinicInvite invite = inviteRepository.save(ClinicInvite.builder()
                    .clinicId(clinicId)
                    .email("davet@example.com")
                    .tokenHash(sha256("TOKEN-123"))
                    .expiresAt(OffsetDateTime.now().plusDays(3))
                    .createdBy(UUID.randomUUID())
                    .build());

            mockMvc.perform(delete("/clinics/" + clinicId + "/invites/" + invite.getId())
                            .with(jwt().jwt(j -> j.subject(doctorId.toString()))
                                    .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Bu işlem için bu klinikte clinic_admin olmalısınız."));
        }

        @Test
        @DisplayName("PATCH /clinics/{id}/members/{userId}/disable - Authenticated normal üye (clinic_admin değil) -> 403 Forbidden")
        void disableMember_authenticatedNonAdmin_returns403() throws Exception {
            UUID doctorId = UUID.randomUUID();
            UUID targetUserId = UUID.randomUUID();
            membershipRepository.save(ClinicMembership.builder()
                    .userId(doctorId)
                    .clinicId(clinicId)
                    .role("doctor")
                    .isClinicAdmin(false)
                    .status("active")
                    .joinedAt(OffsetDateTime.now())
                    .build());

            mockMvc.perform(patch("/clinics/" + clinicId + "/members/" + targetUserId + "/disable")
                            .with(jwt().jwt(j -> j.subject(doctorId.toString()))
                                    .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Bu işlem için bu klinikte clinic_admin olmalısınız."));
        }

        @Test
        @DisplayName("POST /visits (otomatik clinicId tespiti) - Hiç aktif klinik üyeliği yok -> 403 Forbidden")
        void createVisit_noActiveMembership_returns403() throws Exception {
            UUID userIdWithoutClinic = UUID.randomUUID();

            mockMvc.perform(post("/visits")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"petId\":\"" + pet.getId() + "\",\"chiefComplaint\":\"Aşı kontrolü\"}")
                            .with(jwt().jwt(j -> j.subject(userIdWithoutClinic.toString()))
                                    .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Aktif klinik uyeliginiz bulunmamaktadir."));
        }

        @Test
        @DisplayName("GET /visits/code/{code} (otomatik clinicId tespiti) - Hiç aktif klinik üyeliği yok -> 403 Forbidden")
        void getPatientByCode_noActiveMembership_returns403() throws Exception {
            UUID userIdWithoutClinic = UUID.randomUUID();

            mockMvc.perform(get("/visits/code/" + pet.getUniqueCode())
                            .with(jwt().jwt(j -> j.subject(userIdWithoutClinic.toString()))
                                    .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Aktif klinik uyeliginiz bulunmamaktadir."));
        }

        @Test
        @DisplayName("POST /clinics/invites/accept - Farklı e-posta için oluşturulmuş davet -> 403 Forbidden")
        void acceptInvite_emailMismatch_returns403() throws Exception {
            UUID userId = UUID.randomUUID();
            inviteRepository.save(ClinicInvite.builder()
                    .clinicId(clinicId)
                    .email("hedef@example.com")
                    .tokenHash(sha256("TOKEN-EMAIL-MISMATCH"))
                    .expiresAt(OffsetDateTime.now().plusDays(3))
                    .createdBy(UUID.randomUUID())
                    .build());

            mockMvc.perform(post("/clinics/invites/accept")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"token\":\"TOKEN-EMAIL-MISMATCH\"}")
                            .with(jwt().jwt(j -> j.subject(userId.toString())
                                    .claim("email", "baska@example.com"))))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value("FORBIDDEN"))
                    .andExpect(jsonPath("$.message").value("Bu davet farklı bir e-posta adresi için oluşturulmuştur."));
        }
    }
}
