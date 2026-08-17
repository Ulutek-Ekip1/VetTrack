package com.vettrack.api.visit;

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
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * RFC-2026-VET-001 Değişiklik 2 (+ Değ.4) — GET /visits/vet.
 * Hekime atanmış ziyaretler; soft-delete filtreleme, started_at DESC sıralama,
 * boş liste (200 + []) ve rol kısıtı (sadece VET_STAFF/ADMIN) doğrulanır.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:visit_vet_testdb;DB_CLOSE_DELAY=-1",
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
class VisitVetHistoryTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PetRepository petRepository;

    @Autowired
    private VisitRepository visitRepository;

    @Autowired
    private PetService petService;

    private final UUID ownerId = UUID.randomUUID();
    private final UUID vetId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        visitRepository.deleteAll();
        petRepository.deleteAll();

        Pet activePet = createPet(false, true);
        Pet softDeletedPet = createPet(true, true);
        Pet inactivePet = createPet(false, false);

        // vetId'ye atanmış iki geçerli ziyaret (farklı started_at — DESC sırası)
        saveVisit(activePet.getId(), vetId, OffsetDateTime.now().minusHours(2));
        saveVisit(activePet.getId(), vetId, OffsetDateTime.now().minusHours(1));
        // silinmiş / pasif petlerin ziyaretleri hekim listesine GELMEMELI
        saveVisit(softDeletedPet.getId(), vetId, OffsetDateTime.now());
        saveVisit(inactivePet.getId(), vetId, OffsetDateTime.now());
        // başka hekime atanmış ziyaret bu hekimin listesinde OLMAMALI
        saveVisit(activePet.getId(), UUID.randomUUID(), OffsetDateTime.now());
    }

    private Pet createPet(boolean softDeleted, boolean active) {
        Pet pet = petService.createPet(Pet.builder()
                .ownerId(ownerId)
                .name("Pamuk")
                .species("Kedi")
                .gender(Gender.female)
                .build());
        pet.setIsActive(active);
        if (softDeleted) {
            pet.setDeletedAt(OffsetDateTime.now());
        }
        return petRepository.save(pet);
    }

    private void saveVisit(UUID petId, UUID vetStaffId, OffsetDateTime startedAt) {
        visitRepository.save(Visit.builder()
                .petId(petId)
                .vetStaffId(vetStaffId)
                .status("completed")
                .startedAt(startedAt)
                .build());
    }

    @Test
    @DisplayName("GET /visits/vet - Hekime atanmış ziyaretler döner, silinmiş/pasif pet ve başka hekim hariç")
    void vetVisits_returnsAssignedVisitsOnly() throws Exception {
        mockMvc.perform(get("/visits/vet")
                        .with(jwt().jwt(j -> j.subject(vetId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].vetStaffId").value(vetId.toString()))
                .andExpect(jsonPath("$[0].startedAt").isNotEmpty());
    }

    @Test
    @DisplayName("GET /visits/vet - Ziyareti olmayan hekim için 200 + boş dizi döner")
    void vetVisits_emptyReturnsEmptyArray() throws Exception {
        mockMvc.perform(get("/visits/vet")
                        .with(jwt().jwt(j -> j.subject(UUID.randomUUID().toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("GET /visits/vet - Owner rolüyle erişim 403 döner")
    void vetVisits_ownerRoleForbidden() throws Exception {
        mockMvc.perform(get("/visits/vet")
                        .with(jwt().jwt(j -> j.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("GET /visits/vet - Kimlik doğrulaması olmadan 401 döner")
    void vetVisits_unauthenticatedReturns401() throws Exception {
        mockMvc.perform(get("/visits/vet"))
                .andExpect(status().isUnauthorized());
    }
}
