package com.vettrack.api.auth;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:openapi_testdb;DB_CLOSE_DELAY=-1",
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
@Transactional
public class NewOpenApiEndpointsTest {

    @org.springframework.boot.test.mock.mockito.MockBean
    private org.springframework.web.client.RestTemplate restTemplate;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private OwnerRepository ownerRepository;

    @Autowired
    private PetRepository petRepository;

    @Test
    void testDeleteMyAccount_SoftDelete_204_And_Pets_SoftDeleted() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(ownerId)
                .email("test-delete-" + ownerId + "@vettrack.local")
                .fullName("Test Delete Owner")
                .role("owner")
                .isActive(true)
                .build();
        ownerRepository.save(owner);

        Pet pet = Pet.builder()
                .ownerId(ownerId)
                .name("Pamuk")
                .species("kedi")
                .breed("Van Kedisi")
                .gender(Gender.female)
                .uniqueCode("PMK123")
                .isActive(true)
                .build();
        Pet savedPet = petRepository.save(pet);

        mockMvc.perform(delete("/auth/me").with(jwt().jwt(builder -> builder
                .subject(ownerId.toString())
                .claim("email", owner.getEmail())
                .claim("user_metadata", Map.of("role", "owner", "name", owner.getFullName()))
        )))
                .andExpect(status().isNoContent());

        Owner updatedOwner = ownerRepository.findById(ownerId).orElseThrow();
        assertFalse(updatedOwner.getIsActive());

        Pet updatedPet = petRepository.findById(savedPet.getId()).orElseThrow();
        assertFalse(updatedPet.getIsActive());
        assertNotNull(updatedPet.getDeletedAt());
    }

    @Test
    void testForgotPassword_UserEnumerationGuard() throws Exception {
        String payload = """
                {
                    "email": "nonexistent-user@vettrack.local"
                }
                """;

        mockMvc.perform(post("/auth/forgot-password")
                .contentType(MediaType.APPLICATION_JSON)
                .content(payload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Eğer e-posta adresi sistemimizde kayıtlıysa, şifre sıfırlama bağlantısı gönderilmiştir."));
    }

    @Test
    void testGetPetVisitsPaginated_Success() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet pet = Pet.builder()
                .ownerId(ownerId)
                .name("Boncuk")
                .species("kedi")
                .breed("tekir")
                .gender(Gender.female)
                .uniqueCode("BCK123")
                .build();
        Pet savedPet = petRepository.save(pet);

        mockMvc.perform(get("/pets/" + savedPet.getId() + "/visits?page=0&size=10").with(jwt().jwt(builder -> builder
                .subject(ownerId.toString())
                .claim("email", "owner@vettrack.local")
                .claim("user_metadata", Map.of("role", "owner"))
        )))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.totalElements").value(0));
    }

    @Test
    void testGetPetVisitsPaginated_SubstringRoleAttack_Returns403() throws Exception {
        UUID realOwnerId = UUID.randomUUID();
        UUID attackerUserId = UUID.randomUUID();

        Pet pet = Pet.builder()
                .ownerId(realOwnerId)
                .name("Karabaş")
                .species("köpek")
                .gender(Gender.male)
                .uniqueCode("KRB999")
                .build();
        Pet savedPet = petRepository.save(pet);

        // Attacker presents a claim containing 'vet' substring like 'not-a-vet'
        mockMvc.perform(get("/pets/" + savedPet.getId() + "/visits?page=0&size=10").with(jwt().jwt(builder -> builder
                .subject(attackerUserId.toString())
                .claim("email", "attacker@evil.local")
                .claim("user_metadata", Map.of("role", "not-a-vet"))
        )))
                .andExpect(status().isForbidden());
    }

    @Test
    void testInactiveUser_Returns401() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(ownerId)
                .email("test-inactive-" + ownerId + "@vettrack.local")
                .fullName("Inactive Owner")
                .role("owner")
                .isActive(false) // Inactive user
                .build();
        ownerRepository.save(owner);

        // Attempt to access a protected endpoint
        mockMvc.perform(get("/auth/me").with(jwt().jwt(builder -> builder
                .subject(ownerId.toString())
                .claim("email", owner.getEmail())
                .claim("user_metadata", Map.of("role", "owner", "name", owner.getFullName()))
        )))
                .andExpect(status().isUnauthorized());
    }
}
