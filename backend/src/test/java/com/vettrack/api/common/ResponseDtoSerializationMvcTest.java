package com.vettrack.api.common;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerRepository;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:dto_testdb;DB_CLOSE_DELAY=-1",
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
class ResponseDtoSerializationMvcTest {

    @MockitoBean
    private RestTemplate restTemplate;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private OwnerRepository ownerRepository;

    @Autowired
    private PetRepository petRepository;

    @Test
    @DisplayName("GET /auth/me JSON çıktısında profile.role ve profile.isActive bulunmamalı")
    void testAuthMeDoesNotLeakSensitiveProfileFields() throws Exception {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(userId)
                .email("owner@test.com")
                .fullName("Test Owner")
                .role("owner")
                .isActive(true)
                .phone("+905551234567")
                .build();
        ownerRepository.save(owner);

        mockMvc.perform(get("/auth/me")
                        .with(jwt().jwt(builder -> builder
                                .subject(userId.toString())
                                .claim("email", "owner@test.com")
                                .claim("user_metadata", Map.of("role", "owner")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(userId.toString()))
                .andExpect(jsonPath("$.email").value("owner@test.com"))
                .andExpect(jsonPath("$.role").value("owner"))
                .andExpect(jsonPath("$.profile.id").value(userId.toString()))
                .andExpect(jsonPath("$.profile.fullName").value("Test Owner"))
                .andExpect(jsonPath("$.profile.email").value("owner@test.com"))
                .andExpect(jsonPath("$.profile.phone").value("+905551234567"))
                .andExpect(jsonPath("$.profile.role").doesNotExist())
                .andExpect(jsonPath("$.profile.isActive").doesNotExist())
                .andExpect(jsonPath("$.profile.is_active").doesNotExist());
    }

    @Test
    @DisplayName("GET /owners/me JSON çıktısında role ve isActive alanları bulunmamalı")
    void testOwnersMeDoesNotLeakRoleAndIsActive() throws Exception {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(userId)
                .email("ayse@example.com")
                .fullName("Ayşe Yılmaz")
                .role("owner")
                .isActive(true)
                .phone("+905559876543")
                .build();
        ownerRepository.save(owner);

        mockMvc.perform(get("/owners/me")
                        .with(jwt().jwt(builder -> builder.subject(userId.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(userId.toString()))
                .andExpect(jsonPath("$.fullName").value("Ayşe Yılmaz"))
                .andExpect(jsonPath("$.email").value("ayse@example.com"))
                .andExpect(jsonPath("$.phone").value("+905559876543"))
                .andExpect(jsonPath("$.role").doesNotExist())
                .andExpect(jsonPath("$.isActive").doesNotExist())
                .andExpect(jsonPath("$.is_active").doesNotExist());
    }

    @Test
    @DisplayName("GET /pets/{id} ve GET /pets JSON çıktısında isActive ve deletedAt alanları bulunmamalı")
    void testPetsEndpointsDoNotLeakIsActiveAndDeletedAt() throws Exception {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(userId)
                .email("petowner@test.com")
                .fullName("Pet Owner")
                .role("owner")
                .isActive(true)
                .build();
        ownerRepository.save(owner);

        Pet pet = Pet.builder()
                .ownerId(userId)
                .name("Pamuk")
                .species("Kedi")
                .breed("Tekir")
                .gender(Gender.female)
                .birthDate(LocalDate.of(2022, 1, 15))
                .uniqueCode("ABC999")
                .isActive(true)
                .deletedAt(null)
                .build();
        Pet savedPet = petRepository.save(pet);

        // 1. GET /pets/{id}
        mockMvc.perform(get("/pets/" + savedPet.getId())
                        .with(jwt().jwt(builder -> builder.subject(userId.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(savedPet.getId().toString()))
                .andExpect(jsonPath("$.ownerId").value(userId.toString()))
                .andExpect(jsonPath("$.name").value("Pamuk"))
                .andExpect(jsonPath("$.species").value("Kedi"))
                .andExpect(jsonPath("$.uniqueCode").value("ABC999"))
                .andExpect(jsonPath("$.isActive").doesNotExist())
                .andExpect(jsonPath("$.is_active").doesNotExist())
                .andExpect(jsonPath("$.deletedAt").doesNotExist())
                .andExpect(jsonPath("$.deleted_at").doesNotExist());

        // 2. GET /pets
        mockMvc.perform(get("/pets")
                        .with(jwt().jwt(builder -> builder.subject(userId.toString()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(savedPet.getId().toString()))
                .andExpect(jsonPath("$[0].name").value("Pamuk"))
                .andExpect(jsonPath("$[0].isActive").doesNotExist())
                .andExpect(jsonPath("$[0].is_active").doesNotExist())
                .andExpect(jsonPath("$[0].deletedAt").doesNotExist())
                .andExpect(jsonPath("$[0].deleted_at").doesNotExist());
    }

    @Test
    @DisplayName("GET /auth/me vet_staff rolüyle çağrıldığında profile alanında clinic-staff alanları ve isActive bulunmamalı, OwnerResponse dönmeli")
    void testAuthMeVetStaffDoesNotLeakSensitiveFieldsOrClinicStaffFields() throws Exception {
        UUID userId = UUID.randomUUID();
        Owner owner = Owner.builder()
                .id(userId)
                .email("dr.mehmet@vetklinik.com")
                .fullName("Dr. Mehmet Yılmaz")
                .role("vet_staff")
                .isActive(true)
                .phone("+905559998877")
                .build();
        ownerRepository.save(owner);

        mockMvc.perform(get("/auth/me")
                        .with(jwt().jwt(builder -> builder
                                .subject(userId.toString())
                                .claim("email", "dr.mehmet@vetklinik.com")
                                .claim("user_metadata", Map.of("role", "vet_staff")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(userId.toString()))
                .andExpect(jsonPath("$.email").value("dr.mehmet@vetklinik.com"))
                .andExpect(jsonPath("$.role").value("vet_staff"))
                .andExpect(jsonPath("$.clinicMemberships").isArray())
                .andExpect(jsonPath("$.clinic_memberships").doesNotExist())
                .andExpect(jsonPath("$.profile.id").value(userId.toString()))
                .andExpect(jsonPath("$.profile.fullName").value("Dr. Mehmet Yılmaz"))
                .andExpect(jsonPath("$.profile.email").value("dr.mehmet@vetklinik.com"))
                .andExpect(jsonPath("$.profile.phone").value("+905559998877"))
                .andExpect(jsonPath("$.profile.role").doesNotExist())
                .andExpect(jsonPath("$.profile.isActive").doesNotExist())
                .andExpect(jsonPath("$.profile.is_active").doesNotExist())
                .andExpect(jsonPath("$.profile.staffRole").doesNotExist())
                .andExpect(jsonPath("$.profile.licenseNumber").doesNotExist())
                .andExpect(jsonPath("$.profile.clinicId").doesNotExist());
    }
}
