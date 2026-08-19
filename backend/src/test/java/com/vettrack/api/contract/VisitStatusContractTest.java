package com.vettrack.api.contract;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.is;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * API-CONTRACT-01 (P0, QA Test Raporu 19.08.2026) — docs/openapi.yaml Visit status enum'ı
 * (VisitResponse/VisitDetailResponse: ongoing/completed/cancelled) ile gerçek
 * PATCH /visits/{id}/status davranışının birebir eşleştiğini doğrular. "ended" artık kabul
 * edilmiyor (hiçbir istemci hiç göndermiyordu, kalıcı bir status değeri değildi) — bu test
 * gelecekte tekrar sessizce eklenmesini de yakalar.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:visitstatuscontractdb;DB_CLOSE_DELAY=-1",
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
class VisitStatusContractTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private PetRepository petRepository;
    @Autowired
    private VisitRepository visitRepository;
    @Autowired
    private ClinicMembershipRepository clinicMembershipRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private UUID vetUserId;
    private UUID clinicId;

    @BeforeEach
    void setUp() {
        visitRepository.deleteAll();
        petRepository.deleteAll();
        clinicMembershipRepository.deleteAll();

        vetUserId = UUID.randomUUID();
        clinicId = UUID.randomUUID();

        ClinicMembership membership = new ClinicMembership();
        membership.setClinicId(clinicId);
        membership.setUserId(vetUserId);
        membership.setRole("vet");
        membership.setStatus("active");
        clinicMembershipRepository.save(membership);
    }

    private Visit createOngoingVisit() {
        Pet pet = petRepository.save(Pet.builder()
                .ownerId(UUID.randomUUID())
                .name("Duman")
                .breed("Tekir")
                .species("Kedi")
                .gender(Gender.male)
                .uniqueCode("DMN001")
                .build());
        return visitRepository.save(Visit.builder()
                .petId(pet.getId())
                .clinicId(clinicId)
                .vetStaffId(vetUserId)
                .status("ongoing")
                .startedAt(OffsetDateTime.now())
                .build());
    }

    @Test
    @DisplayName("status=completed -> 200, openapi.yaml'daki enum'a uygun 'completed' döner")
    void whenStatusCompleted_thenReturnsCompletedMatchingContract() throws Exception {
        Visit visit = createOngoingVisit();

        mockMvc.perform(patch("/visits/" + visit.getId() + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("status", "completed")))
                        .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("completed")));
    }

    @Test
    @DisplayName("status=cancelled -> 200, openapi.yaml'daki enum'a uygun 'cancelled' döner (QA'in tespit ettiği eksik değer)")
    void whenStatusCancelled_thenReturnsCancelledMatchingContract() throws Exception {
        Visit visit = createOngoingVisit();

        mockMvc.perform(patch("/visits/" + visit.getId() + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("status", "cancelled")))
                        .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("cancelled")));
    }

    @Test
    @DisplayName("status alanı hiç gönderilmezse -> varsayılan olarak 'completed' uygulanır (openapi.yaml default: completed)")
    void whenStatusFieldOmitted_thenDefaultsToCompleted() throws Exception {
        Visit visit = createOngoingVisit();

        mockMvc.perform(patch("/visits/" + visit.getId() + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}")
                        .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("completed")));
    }

    @Test
    @DisplayName("status=ended artık reddedilmeli — kalıcı bir status değeri değildi, hiçbir istemci göndermiyordu, dokümante edilmemiş sessiz eş anlamlı kaldırıldı")
    void whenStatusEnded_thenRejectedAsInvalid() throws Exception {
        Visit visit = createOngoingVisit();

        mockMvc.perform(patch("/visits/" + visit.getId() + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("status", "ended")))
                        .with(jwt().jwt(b -> b.subject(vetUserId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isBadRequest());
    }
}
