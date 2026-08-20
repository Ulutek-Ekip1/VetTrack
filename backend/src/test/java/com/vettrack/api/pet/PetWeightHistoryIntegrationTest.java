package com.vettrack.api.pet;

import com.vettrack.api.pet.dto.PetWeightHistoryResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:weight_testdb;DB_CLOSE_DELAY=-1",
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
class PetWeightHistoryIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PetRepository petRepository;

    @Autowired
    private PetWeightHistoryRepository petWeightHistoryRepository;

    @Autowired
    private PetService petService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        petWeightHistoryRepository.deleteAll();
        petRepository.deleteAll();
    }

    private Pet createTestPet(UUID ownerId, Double weight) {
        Pet pet = Pet.builder()
                .ownerId(ownerId)
                .name("Pamuk")
                .species("Kedi")
                .breed("Van")
                .gender(Gender.female)
                .weight(weight)
                .microchipNo("900215000123456")
                .isSpayedOrNeutered(true)
                .bloodType("DEA 1.1 (+)")
                .color("Beyaz")
                .allergies("Tavuk alerjisi")
                .chronicIllnesses("Yok")
                .build();
        return petService.createPet(pet);
    }

    @Test
    @DisplayName("Pet oluşturulurken veya güncellenirken kilo geçmişi otomatik kaydedilmeli ve listelenebilmeli")
    void shouldTrackAndReturnWeightHistory() {
        UUID ownerId = UUID.randomUUID();

        Pet createdPet = createTestPet(ownerId, 21.0);
        assertNotNull(createdPet.getId());

        // Add more weight records via service with specific dates
        LocalDate nextMonth = LocalDate.now().plusMonths(1);
        LocalDate twoMonthsLater = LocalDate.now().plusMonths(2);
        petService.recordWeight(createdPet.getId(), 22.0, nextMonth, ownerId);
        petService.recordWeight(createdPet.getId(), 23.0, twoMonthsLater, ownerId);

        // Query weight history
        List<PetWeightHistoryResponse> history = petService.getWeightHistory(createdPet.getId());

        assertNotNull(history);
        assertEquals(3, history.size());
        assertEquals(21.0, history.get(0).getWeight());
        assertEquals(LocalDate.now(), history.get(0).getDate());
        assertEquals(22.0, history.get(1).getWeight());
        assertEquals(nextMonth, history.get(1).getDate());
        assertEquals(23.0, history.get(2).getWeight());
        assertEquals(twoMonthsLater, history.get(2).getDate());
    }

    @Test
    @DisplayName("GET /pets/{id}/weight-history - Sahip kilo geçmişini 200 ile alabilmeli")
    void shouldReturnWeightHistoryViaEndpointForOwner() throws Exception {
        UUID ownerId = UUID.randomUUID();

        Pet createdPet = createTestPet(ownerId, 21.0);

        mockMvc.perform(get("/pets/" + createdPet.getId() + "/weight-history")
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].weight").value(21.0))
                .andExpect(jsonPath("$[0].date").isNotEmpty());
    }

    @Test
    @DisplayName("GET /pets/{id}/weight-history - Başka kullanıcı erişmeye çalıştığında 403 dönmeli")
    void shouldReturn403ForUnauthorizedUser() throws Exception {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        Pet createdPet = createTestPet(ownerId, 21.0);

        mockMvc.perform(get("/pets/" + createdPet.getId() + "/weight-history")
                        .with(jwt().jwt(jwt -> jwt.subject(otherUserId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isForbidden());
    }

    // ===== Yeni Test Senaryoları =====

    @Test
    @DisplayName("PUT /pets/{id} - Sadece weight göndererek güncelleme yapılabilmeli (name opsiyonel)")
    void shouldUpdateWeightOnlyWithoutName() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        String requestBody = objectMapper.writeValueAsString(Map.of("weight", 22.5));

        mockMvc.perform(put("/pets/" + createdPet.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.weight").value(22.5))
                .andExpect(jsonPath("$.name").value("Pamuk")); // name değişmemeli
    }

    @Test
    @DisplayName("PUT /pets/{id} - Negatif kilo değeri 400 dönmeli")
    void shouldReject400ForNegativeWeight() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        String requestBody = objectMapper.writeValueAsString(Map.of("weight", -5.0));

        mockMvc.perform(put("/pets/" + createdPet.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("PUT /pets/{id} - Sıfır kilo değeri 400 dönmeli")
    void shouldReject400ForZeroWeight() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        String requestBody = objectMapper.writeValueAsString(Map.of("weight", 0));

        mockMvc.perform(put("/pets/" + createdPet.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Aynı kilo değeri tekrar kaydedildiğinde history'de yeni kayıt oluşmamalı")
    void shouldNotDuplicateWeightHistoryForSameValue() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        // Aynı değerle tekrar kaydet
        petService.recordWeight(createdPet.getId(), 21.0, LocalDate.now(), ownerId);

        List<PetWeightHistoryResponse> history = petService.getWeightHistory(createdPet.getId());
        assertEquals(1, history.size(), "Aynı kilo değeri tekrar kaydedilmemeli");
    }

    @Test
    @DisplayName("Farklı kilo değerleri her seferinde history'ye eklenmeli")
    void shouldRecordDifferentWeightValues() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        petService.recordWeight(createdPet.getId(), 22.0, LocalDate.now(), ownerId);
        petService.recordWeight(createdPet.getId(), 21.0, LocalDate.now(), ownerId); // tekrar farklı değere dönüş

        List<PetWeightHistoryResponse> history = petService.getWeightHistory(createdPet.getId());
        assertEquals(3, history.size(), "Farklı kilo değerleri kaydedilmeli");
    }

    @Test
    @DisplayName("Service katmanında negatif kilo değeri IllegalArgumentException fırlatmalı")
    void shouldThrowExceptionForNegativeWeightInService() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        assertThrows(IllegalArgumentException.class, () ->
            petService.recordWeight(createdPet.getId(), -1.0, LocalDate.now(), ownerId)
        );
    }

    @Test
    @DisplayName("Service katmanında sıfır kilo değeri IllegalArgumentException fırlatmalı")
    void shouldThrowExceptionForZeroWeightInService() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        assertThrows(IllegalArgumentException.class, () ->
            petService.recordWeight(createdPet.getId(), 0.0, LocalDate.now(), ownerId)
        );
    }

    @Test
    @DisplayName("PUT /pets/{id} - Boş name gönderildiğinde 400 dönmeli")
    void shouldReject400ForBlankName() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        String requestBody = objectMapper.writeValueAsString(Map.of("name", "  "));

        mockMvc.perform(put("/pets/" + createdPet.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("GET /pets/{id}/weight-history?page=0&size=2 - Sayfalandırılmış kilo geçmişi dönebilmeli")
    void shouldReturnPaginatedWeightHistoryViaEndpoint() throws Exception {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        petService.recordWeight(createdPet.getId(), 22.0, LocalDate.now().plusMonths(1), ownerId);
        petService.recordWeight(createdPet.getId(), 23.0, LocalDate.now().plusMonths(2), ownerId);

        mockMvc.perform(get("/pets/" + createdPet.getId() + "/weight-history?page=0&size=2")
                        .with(jwt().jwt(jwt -> jwt.subject(ownerId.toString()))
                                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.totalElements").value(3))
                .andExpect(jsonPath("$.totalPages").value(2));
    }

    @Test
    @DisplayName("Service katmanında 2000 kg üstü kilo değeri IllegalArgumentException fırlatmalı")
    void shouldThrowExceptionForWeightExceeding2000InService() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        assertThrows(IllegalArgumentException.class, () ->
            petService.recordWeight(createdPet.getId(), 2000.1, LocalDate.now(), ownerId)
        );
    }

    @Test
    @DisplayName("Geriye dönük (backdated) kayıt eklendiğinde dedup kontrolü en son EKLENEN kayda göre yapılmalı, en güncel tarihli kayda göre değil")
    void shouldDedupAgainstMostRecentlyInsertedRecordNotMostRecentDate() {
        UUID ownerId = UUID.randomUUID();
        // weight=null: createPet otomatik kayıt atmasın, ilk kayıt biz kontrol edelim
        Pet pet = Pet.builder()
                .ownerId(ownerId)
                .name("Pamuk")
                .species("Kedi")
                .gender(Gender.female)
                .build();
        Pet createdPet = petService.createPet(pet);

        // Önce bugünün kilosunu gir (kronolojik olarak en güncel tarih)
        petService.recordWeight(createdPet.getId(), 22.0, LocalDate.now(), ownerId);

        // Sonra geçmişe dönük bir ziyaretin kilosunu gir (recordedAt daha eski ama insertion sırası daha yeni)
        LocalDate lastWeek = LocalDate.now().minusDays(7);
        petService.recordWeight(createdPet.getId(), 21.0, lastWeek, ownerId);
        // Aynı geçmiş kilo tekrar girilirse (örn. formu tekrar submit etme) hâlâ dedup çalışmalı
        petService.recordWeight(createdPet.getId(), 21.0, lastWeek, ownerId);

        List<PetWeightHistoryResponse> history = petService.getWeightHistory(createdPet.getId());
        assertEquals(2, history.size(),
            "Backdated kayıt bugünün kilosuna göre değil, kendisinden önce EKLENEN kayda göre dedup edilmeli");
    }

    @Test
    @DisplayName("Service katmanında NaN veya Infinite kilo değeri IllegalArgumentException fırlatmalı")
    void shouldThrowExceptionForNaNOrInfiniteWeightInService() {
        UUID ownerId = UUID.randomUUID();
        Pet createdPet = createTestPet(ownerId, 21.0);

        assertThrows(IllegalArgumentException.class, () ->
            petService.recordWeight(createdPet.getId(), Double.NaN, LocalDate.now(), ownerId)
        );

        assertThrows(IllegalArgumentException.class, () ->
            petService.recordWeight(createdPet.getId(), Double.POSITIVE_INFINITY, LocalDate.now(), ownerId)
        );
    }
}
