package com.vettrack.api.pet;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;
import com.vettrack.api.clinic.ClinicMembership;
import com.vettrack.api.clinic.ClinicMembershipRepository;
import com.vettrack.api.clinic.Clinic;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:pettestdb;DB_CLOSE_DELAY=-1",
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
class PetSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PetRepository petRepository;
    @Autowired
    private ClinicMembershipRepository clinicMembershipRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private UUID owner1Id;
    private UUID owner2Id;

    private Pet owner1Pet;
    private Pet owner2Pet;

    @BeforeEach
    void setUp() {
        petRepository.deleteAll();

        owner1Id = UUID.randomUUID();
        owner2Id = UUID.randomUUID();

        owner1Pet = petRepository.save(Pet.builder()
                .ownerId(owner1Id)
                .name("Pamuk")
                .breed("Van Kedisi")
                .species("Kedi")
                .gender(Gender.female)
                .uniqueCode("PMK123")
                .build());

        owner2Pet = petRepository.save(Pet.builder()
                .ownerId(owner2Id)
                .name("Karabaş")
                .breed("Kangal")
                .species("Köpek")
                .gender(Gender.male)
                .uniqueCode("KRB456")
                .build());
    }

    @Test
    @DisplayName("JWT olmadan istek atıldığında 401 Unauthorized dönmeli")
    void whenUnauthenticated_thenUnauthorized() throws Exception {
        mockMvc.perform(get("/pets"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(get("/pets/" + owner1Pet.getId()))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Giriş yapmış sahibin sadece kendi pet listesini alabildiğini (GET /pets) doğrula")
    void whenOwnerRequestsPets_thenReturnsOnlyOwnPets() throws Exception {
        mockMvc.perform(get("/pets")
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id", is(owner1Pet.getId().toString())))
                .andExpect(jsonPath("$[0].name", is("Pamuk")));
    }

    @Test
    @DisplayName("Bir sahibin başka bir sahibe ait petId ile GET /pets/{id} yapması 403 Forbidden dönmeli")
    void whenOwnerGetsOtherOwnersPet_thenForbidden() throws Exception {
        mockMvc.perform(get("/pets/" + owner1Pet.getId())
                .with(jwt().jwt(builder -> builder.subject(owner2Id.toString()))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Bir sahibin başka bir sahibe ait petId ile PUT /pets/{id} yapması 403 Forbidden dönmeli")
    void whenOwnerUpdatesOtherOwnersPet_thenForbidden() throws Exception {
        PetUpdateRequest updateRequest = new PetUpdateRequest();
        updateRequest.setName("Hacklendi");
        updateRequest.setBreed("Van Kedisi");
        updateRequest.setSpecies("Kedi");
        updateRequest.setGender(Gender.female);

        mockMvc.perform(put("/pets/" + owner1Pet.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(jwt().jwt(builder -> builder.subject(owner2Id.toString()))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Sahip kendi petini GET /pets/{id} ile alabildiğini doğrula (200 OK)")
    void whenOwnerGetsOwnPet_thenOk() throws Exception {
        mockMvc.perform(get("/pets/" + owner1Pet.getId())
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(owner1Pet.getId().toString())))
                .andExpect(jsonPath("$.name", is("Pamuk")));
    }

    @Test
    @DisplayName("Sahip kendi petini PUT /pets/{id} ile güncelleyebildiğini doğrula (200 OK)")
    void whenOwnerUpdatesOwnPet_thenOk() throws Exception {
        PetUpdateRequest updateRequest = new PetUpdateRequest();
        updateRequest.setName("Pamuk Yeni");
        updateRequest.setBreed("Van Kedisi");
        updateRequest.setSpecies("Kedi");
        updateRequest.setGender(Gender.female);

        mockMvc.perform(put("/pets/" + owner1Pet.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is("Pamuk Yeni")));
    }

    @Test
    @DisplayName("Giriş yapmış kullanıcı hatalı/boş veri gönderdiğinde (PUT /pets/{id}) 400 Bad Request dönmeli")
    void whenUpdatePetWithInvalidPayload_thenReturns400BadRequest() throws Exception {
        PetUpdateRequest invalidRequest = new PetUpdateRequest();
        invalidRequest.setName(""); // @NotBlank validation ihlali

        mockMvc.perform(put("/pets/" + owner1Pet.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequest))
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Var olmayan bir petId ile GET veya PUT yapıldığında 404 Not Found dönmeli")
    void whenRequestNonExistentPet_thenReturns404NotFound() throws Exception {
        UUID randomNonExistentId = UUID.randomUUID();

        mockMvc.perform(get("/pets/" + randomNonExistentId)
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isNotFound());

        PetUpdateRequest updateRequest = new PetUpdateRequest();
        updateRequest.setName("Test Name");
        updateRequest.setBreed("Test Breed");
        updateRequest.setSpecies("Köpek");
        updateRequest.setGender(Gender.female);

        mockMvc.perform(put("/pets/" + randomNonExistentId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Bir sahibin başka bir sahibe ait petin fotoğrafını DELETE /pets/{id}/photo ile silmesi 403 Forbidden dönmeli")
    void whenOwnerDeletesOtherOwnersPetPhoto_thenForbidden() throws Exception {
        mockMvc.perform(delete("/pets/" + owner1Pet.getId() + "/photo")
                .with(jwt().jwt(builder -> builder.subject(owner2Id.toString()))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Sahip, fotoğrafı olmayan kendi petinde DELETE /pets/{id}/photo çağırdığında yine 204 dönmeli (idempotent)")
    void whenOwnerDeletesOwnPetPhotoWithNoExistingPhoto_thenNoContent() throws Exception {
        mockMvc.perform(delete("/pets/" + owner1Pet.getId() + "/photo")
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("Var olmayan bir pet için DELETE /pets/{id}/photo çağrıldığında 404 Not Found dönmeli")
    void whenDeletingPhotoOfNonExistentPet_thenNotFound() throws Exception {
        UUID randomNonExistentId = UUID.randomUUID();

        mockMvc.perform(delete("/pets/" + randomNonExistentId + "/photo")
                .with(jwt().jwt(builder -> builder.subject(owner1Id.toString()))))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Vet (Veteriner) rolündeki kullanıcının başka sahibin petini GET /pets/{id} ile görebildiğini doğrula (200 OK)")
    void whenVetRequestsOtherOwnersPet_thenReturns200Ok() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        ClinicMembership membership = new ClinicMembership();
        membership.setClinicId(UUID.randomUUID());
        membership.setUserId(vetUserId);
        membership.setRole("vet");
        membership.setStatus("active");
        clinicMembershipRepository.save(membership);

        mockMvc.perform(get("/pets/" + owner1Pet.getId())
                .with(jwt().jwt(builder -> builder.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(owner1Pet.getId().toString())))
                .andExpect(jsonPath("$.name", is("Pamuk")));
    }

    @Test
    @DisplayName("Vet rolündeki kullanıcının başka sahibin petini PUT /pets/{id} ile güncellemesi 403 Forbidden dönmeli (vet salt-okunur)")
    void whenVetUpdatesOtherOwnersPet_thenForbidden() throws Exception {
        UUID vetUserId = UUID.randomUUID();
        ClinicMembership membership = new ClinicMembership();
        membership.setClinicId(UUID.randomUUID());
        membership.setUserId(vetUserId);
        membership.setRole("vet");
        membership.setStatus("active");
        clinicMembershipRepository.save(membership);

        PetUpdateRequest updateRequest = new PetUpdateRequest();
        updateRequest.setName("Vet Değiştirdi");
        updateRequest.setBreed("Van Kedisi");
        updateRequest.setSpecies("Kedi");
        updateRequest.setGender(Gender.female);

        mockMvc.perform(put("/pets/" + owner1Pet.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(jwt().jwt(builder -> builder.subject(vetUserId.toString()))
                        .authorities(new SimpleGrantedAuthority("ROLE_VET_STAFF"))))
                .andExpect(status().isForbidden());
    }
}

