package com.vettrack.api.treatment;

import com.vettrack.api.clinic.ClinicMembership;
import com.vettrack.api.clinic.ClinicMembershipRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * BE-SEC-FINDING-01 (P0, QA Test Raporu 19.08.2026) — cross-clinic BOLA regresyon testleri.
 * "Vet olmak" tek başına yeterli olmamalı; hedef ziyaretin/pet'in vet'in aktif kliniğine
 * ait olması zorunlu.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:treatmentsectestdb;DB_CLOSE_DELAY=-1",
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
class TreatmentSecurityTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private PetRepository petRepository;
    @Autowired
    private VisitRepository visitRepository;
    @Autowired
    private ClinicMembershipRepository clinicMembershipRepository;
    @Autowired
    private TreatmentEntryRepository treatmentEntryRepository;

    private Pet pet;
    private Visit visitAtClinicA;
    private UUID clinicAId;
    private UUID clinicBId;

    @BeforeEach
    void setUp() {
        treatmentEntryRepository.deleteAll();
        visitRepository.deleteAll();
        petRepository.deleteAll();
        clinicMembershipRepository.deleteAll();

        clinicAId = UUID.randomUUID();
        clinicBId = UUID.randomUUID();

        pet = petRepository.save(Pet.builder()
                .ownerId(UUID.randomUUID())
                .name("Boncuk")
                .breed("Tekir")
                .species("Kedi")
                .gender(Gender.female)
                .uniqueCode("BNC001")
                .build());

        visitAtClinicA = visitRepository.save(Visit.builder()
                .petId(pet.getId())
                .clinicId(clinicAId)
                .vetStaffId(UUID.randomUUID())
                .status("completed")
                .startedAt(OffsetDateTime.now())
                .build());

        treatmentEntryRepository.save(TreatmentEntry.builder()
                .visitId(visitAtClinicA.getId())
                .type("VACCINE")
                .title("Kuduz aşısı")
                .status(TreatmentStatus.COMPLETED)
                .startDate(OffsetDateTime.now())
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
    @DisplayName("Kendi kliniğindeki (clinicA) vet GET /visits/{visitId}/treatments ile 200 alır")
    void whenVetOfSameClinicRequestsVisitTreatments_thenOk() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicAId);

        mockMvc.perform(get("/visits/" + visitAtClinicA.getId() + "/treatments")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("BOLA fix: Başka klinikteki (clinicB) vet GET /visits/{visitId}/treatments ile 403 alır")
    void whenVetOfDifferentClinicRequestsVisitTreatments_thenForbidden() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicBId);

        mockMvc.perform(get("/visits/" + visitAtClinicA.getId() + "/treatments")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Kendi kliniğindeki vet GET /pets/{petId}/treatments ile 200 alır")
    void whenVetOfSameClinicRequestsPetTreatments_thenOk() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicAId);

        mockMvc.perform(get("/pets/" + pet.getId() + "/treatments")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("BOLA fix: Başka klinikteki vet GET /pets/{petId}/treatments ile 403 alır (bu pet'in o klinikte ziyareti yok)")
    void whenVetOfDifferentClinicRequestsPetTreatments_thenForbidden() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        giveActiveMembership(vetUserId, clinicBId);

        mockMvc.perform(get("/pets/" + pet.getId() + "/treatments")
                .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Pet sahibi kendi petinin tedavi geçmişini GET /pets/{petId}/treatments ile görebilir")
    void whenOwnerRequestsOwnPetTreatments_thenOk() throws Exception {
        mockMvc.perform(get("/pets/" + pet.getId() + "/treatments")
                .with(jwt().jwt(b -> b.subject(pet.getOwnerId().toString()))))
                .andExpect(status().isOk());
    }
}
