package com.vettrack.api.visit;

import com.vettrack.api.clinic.Clinic;
import com.vettrack.api.clinic.ClinicMembership;
import com.vettrack.api.clinic.ClinicMembershipRepository;
import com.vettrack.api.clinic.ClinicRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.pet.PetService;
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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * GET /visits/code/{code} — clinicId artık opsiyonel: verilmezse hekimin tek aktif
 * klinik üyeliği otomatik kullanılır (VisitController.createVisit ile aynı desen).
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:visitcodeautodetectdb;DB_CLOSE_DELAY=-1",
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
class VisitCodeSearchClinicAutodetectTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private PetRepository petRepository;
    @Autowired
    private PetService petService;
    @Autowired
    private VisitRepository visitRepository;
    @Autowired
    private ClinicRepository clinicRepository;
    @Autowired
    private ClinicMembershipRepository membershipRepository;

    private UUID clinicAId;
    private UUID clinicBId;
    private Pet pet;

    @BeforeEach
    void setUp() {
        visitRepository.deleteAll();
        membershipRepository.deleteAll();
        petRepository.deleteAll();
        clinicRepository.deleteAll();

        clinicAId = clinicRepository.save(Clinic.builder().name("A Kliniği").build()).getId();
        clinicBId = clinicRepository.save(Clinic.builder().name("B Kliniği").build()).getId();

        pet = petService.createPet(Pet.builder()
                .ownerId(UUID.randomUUID()).name("Pamuk").species("Kedi").gender(Gender.female).build());

        visitRepository.save(Visit.builder()
                .petId(pet.getId()).clinicId(clinicAId).vetStaffId(UUID.randomUUID())
                .status("completed").startedAt(OffsetDateTime.now()).build());
    }

    private void addMembership(UUID userId, UUID clinicId) {
        membershipRepository.save(ClinicMembership.builder()
                .userId(userId).clinicId(clinicId).role("doctor")
                .isClinicAdmin(false).status("active").joinedAt(OffsetDateTime.now()).build());
    }

    @Test
    @DisplayName("clinicId verilmez + tek aktif üyelik: otomatik tespit edilir, 200 döner")
    void singleActiveMembership_autoResolvesClinicId() throws Exception {
        UUID vetId = UUID.randomUUID();
        addMembership(vetId, clinicAId);

        mockMvc.perform(get("/visits/code/{code}", pet.getUniqueCode())
                        .with(jwt().jwt(j -> j.subject(vetId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pet.id").value(pet.getId().toString()));
    }

    @Test
    @DisplayName("clinicId verilir: eski davranış korunur (explicit override)")
    void explicitClinicId_stillWorks() throws Exception {
        UUID vetId = UUID.randomUUID();
        addMembership(vetId, clinicAId);

        mockMvc.perform(get("/visits/code/{code}", pet.getUniqueCode())
                        .param("clinicId", clinicAId.toString())
                        .with(jwt().jwt(j -> j.subject(vetId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("clinicId verilmez + birden fazla aktif üyelik: 400 (belirtmesi zorunlu)")
    void multipleActiveMemberships_returns400() throws Exception {
        UUID vetId = UUID.randomUUID();
        addMembership(vetId, clinicAId);
        addMembership(vetId, clinicBId);

        mockMvc.perform(get("/visits/code/{code}", pet.getUniqueCode())
                        .with(jwt().jwt(j -> j.subject(vetId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("clinicId verilmez + hiç aktif üyelik yok: 401")
    void noActiveMembership_returns401() throws Exception {
        UUID vetId = UUID.randomUUID();

        mockMvc.perform(get("/visits/code/{code}", pet.getUniqueCode())
                        .with(jwt().jwt(j -> j.subject(vetId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isUnauthorized());
    }
}
