package com.vettrack.api.visit;

import com.vettrack.api.clinic.ClinicMembership;
import com.vettrack.api.clinic.ClinicMembershipRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * BE-SEC-FINDING-01 (P0, QA Test Raporu 19.08.2026) — "VisitController pet visit history
 * alias'ları" (GET /pets/{petId}/visits, /pet/{petId}) cross-clinic BOLA regresyon testleri.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:visit_pethistory_testdb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "FIREBASE_CREDENTIALS_PATH=mock",
    "SENTRY_DSN=https://mock@mock.sentry.io/1234",
    "GEMINI_API_KEY=mock",
    "spring.security.oauth2.resourceserver.jwt.jwk-set-uri=http://localhost:8080/.well-known/jwks.json",
    "supabase.url=http://localhost:8080",
    "supabase.service-key=test-key"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class VisitPetHistorySecurityTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private PetRepository petRepository;
    @Autowired
    private VisitRepository visitRepository;
    @Autowired
    private ClinicMembershipRepository clinicMembershipRepository;

    private Pet pet;
    private UUID clinicAId;
    private UUID clinicBId;
    private Visit visitAtClinicA;

    @BeforeEach
    void setUp() {
        clinicAId = UUID.randomUUID();
        clinicBId = UUID.randomUUID();

        pet = petRepository.save(Pet.builder()
                .ownerId(UUID.randomUUID())
                .name("Zeytin")
                .breed("Sokak Kedisi")
                .species("Kedi")
                .gender(Gender.male)
                .uniqueCode("ZYT001")
                .build());

        visitAtClinicA = visitRepository.save(Visit.builder()
                .petId(pet.getId())
                .clinicId(clinicAId)
                .vetStaffId(UUID.randomUUID())
                .status("completed")
                .startedAt(OffsetDateTime.now())
                .build());

        // Aynı pet, başka bir klinikte de görülmüş — bu kayıt clinicB'li vet'e sızmamalı.
        visitRepository.save(Visit.builder()
                .petId(pet.getId())
                .clinicId(clinicBId)
                .vetStaffId(UUID.randomUUID())
                .status("completed")
                .startedAt(OffsetDateTime.now())
                .build());
    }

    private void giveActiveMembership(UUID vetUserId, UUID clinicId) {
        ClinicMembership membership = new ClinicMembership();
        membership.setClinicId(clinicId);
        membership.setUserId(vetUserId);
        membership.setRole("vet");
        membership.setStatus("active");
        clinicMembershipRepository.save(membership);
    }

    @Test
    @DisplayName("Vet GET /pets/{petId}/visits ile sadece KENDİ kliniğindeki ziyareti görür, diğer klinik sızmaz")
    void whenVetRequestsPetVisits_thenOnlyOwnClinicVisitReturned() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicAId);

        mockMvc.perform(get("/visits/pets/" + pet.getId() + "/visits")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id", org.hamcrest.Matchers.is(visitAtClinicA.getId().toString())))
                .andExpect(jsonPath("$[0].clinicId", org.hamcrest.Matchers.is(clinicAId.toString())));
    }

    @Test
    @DisplayName("BOLA fix: Bu pet'in hiç ziyareti olmayan klinikteki vet GET /pets/{petId}/visits ile 200+boş liste alır (içerik sızmaz, 404/403 gerekmez — /visits/owner ile aynı 'boş liste' konvansiyonu)")
    void whenVetHasNoOverlapWithPetsClinics_thenReturnsEmptyList() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        UUID clinicCId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicCId);

        mockMvc.perform(get("/visits/pets/" + pet.getId() + "/visits")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    @DisplayName("BOLA fix: Hiç aktif klinik üyeliği olmayan vet GET /pets/{petId}/visits ile 403 alır")
    void whenVetHasNoActiveMembershipAtAll_thenForbidden() throws Exception {
        UUID vetUserId = UUID.randomUUID();

        mockMvc.perform(get("/visits/pets/" + pet.getId() + "/visits")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Pet sahibi kendi petinin TÜM kliniklerdeki ziyaret geçmişini görebilir (owner klinik-scope'a tabi değil)")
    void whenOwnerRequestsOwnPetVisits_thenReturnsAllClinics() throws Exception {
        mockMvc.perform(get("/visits/pets/" + pet.getId() + "/visits")
                .with(jwt().jwt(b -> b.subject(pet.getOwnerId().toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }
}
