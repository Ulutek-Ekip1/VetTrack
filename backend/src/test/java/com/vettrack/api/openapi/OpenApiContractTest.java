package com.vettrack.api.openapi;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.yaml.snakeyaml.Yaml;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:contract_testdb;DB_CLOSE_DELAY=-1",
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
@ActiveProfiles("test")
class OpenApiContractTest {

    private static Map<String, Object> openApiSpec;

    @BeforeAll
    @SuppressWarnings("unchecked")
    static void loadOpenApiSpec() throws Exception {
        List<Path> candidatePaths = List.of(
                Paths.get("docs/openapi.yaml"),
                Paths.get("../docs/openapi.yaml"),
                Paths.get("src/main/resources/openapi.yaml"),
                Paths.get("../src/main/resources/openapi.yaml")
        );

        Path foundPath = candidatePaths.stream()
                .filter(Files::exists)
                .findFirst()
                .orElse(null);

        assertNotNull(foundPath, "openapi.yaml dosyası kök veya docs dizinlerinde bulunamadı!");

        Yaml yaml = new Yaml();
        try (InputStream in = Files.newInputStream(foundPath)) {
            openApiSpec = yaml.load(in);
        }

        assertNotNull(openApiSpec, "OpenAPI YAML ayrıştırılamadı.");
    }

    @Test
    @DisplayName("OpenAPI başlık ve sürüm bilgisi tanımlı olmalıdır")
    @SuppressWarnings("unchecked")
    void testOpenApiMetadata() {
        Map<String, Object> info = (Map<String, Object>) openApiSpec.get("info");
        assertNotNull(info, "Info alanı bulunamadı.");
        assertEquals("VetTrack API", info.get("title"));
        assertNotNull(info.get("version"));
    }

    @Test
    @DisplayName("OpenAPI dokümanında tüm kritik uç noktalar bulunmalıdır")
    @SuppressWarnings("unchecked")
    void testRequiredEndpointsExist() {
        Map<String, Object> paths = (Map<String, Object>) openApiSpec.get("paths");
        assertNotNull(paths, "Paths listesi boş olamaz.");

        List<String> requiredPaths = List.of(
                "/auth/register", "/auth/login", "/auth/me",
                "/profiles/me",
                "/pets", "/pets/{id}", "/pets/{id}/weight-history", "/pets/{id}/photo", "/pets/{id}/visits", "/pets/{id}/recommendations",
                "/visits", "/visits/owner", "/visits/vet", "/visits/code/{code}", "/visits/{id}/close",
                "/visits/{visitId}/treatments", "/treatments/{id}",
                "/visits/{visitId}/recommendations",
                "/notifications", "/notifications/unread-count", "/notifications/{id}/read", "/notifications/read-all",
                "/devices/register", "/devices/unregister",
                "/clinics/{clinicId}/invites", "/clinics/invites/accept", "/clinics/invites/{inviteId}",
                "/api/v1/ai/chat", "/api/v1/ai/history", "/api/v1/ai/conversations/{conversationId}", "/api/v1/ai/messages/{id}"
        );

        for (String path : requiredPaths) {
            assertTrue(paths.containsKey(path), "OpenAPI dokümanında eksik endpoint: " + path);
        }
    }

    @Test
    @DisplayName("OpenAPI dokümanında kritik DTO şemaları bulunmalıdır")
    @SuppressWarnings("unchecked")
    void testCoreSchemasExist() {
        Map<String, Object> components = (Map<String, Object>) openApiSpec.get("components");
        assertNotNull(components, "Components nesnesi eksik.");
        Map<String, Object> schemas = (Map<String, Object>) components.get("schemas");
        assertNotNull(schemas, "Components.schemas nesnesi eksik.");

        List<String> requiredSchemas = List.of(
                "ErrorResponse", "RegisterRequest", "LoginRequest", "MeResponse", "ProfileUpdateRequest",
                "PetCreateRequest", "PetResponse", "PetWeightHistoryResponse",
                "VisitCreateRequest", "VisitResponse", "TreatmentCreateRequest", "TreatmentEntryResponse",
                "RecommendationCreateRequest", "RecommendationResponse",
                "NotificationResponse", "NotificationListResponse", "DeviceRegisterRequest",
                "ClinicInviteCreateRequest", "ClinicInviteResponse", "AcceptInviteRequest",
                "AiChatRequest", "AiChatResponse", "ChatMessageDto"
        );

        for (String schemaName : requiredSchemas) {
            assertTrue(schemas.containsKey(schemaName), "Components.schemas içinde eksik DTO: " + schemaName);
        }
    }
}