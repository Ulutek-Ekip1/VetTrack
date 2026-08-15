package com.vettrack.api.ai;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.dto.AiChatResponse;
import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.exception.GeminiApiException;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.AiChatService;
import com.vettrack.api.ai.service.EmergencySafetyService;
import com.vettrack.api.ai.service.GeminiService;
import com.vettrack.api.ai.service.PetContextService;
import com.vettrack.api.common.exception.GlobalExceptionHandler;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.recommendation.Recommendation;
import com.vettrack.api.recommendation.RecommendationResponse;
import com.vettrack.api.recommendation.RecommendationCreateRequest;
import com.vettrack.api.recommendation.RecommendationRepository;
import com.vettrack.api.recommendation.RecommendationService;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitCreateRequest;
import com.vettrack.api.visit.VisitRepository;
import com.vettrack.api.visit.VisitService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class Phase2IntegrationTest {

    @Mock
    private EmergencySafetyService emergencySafetyService;

    @Mock
    private PetContextService petContextService;

    @Mock
    private GeminiService geminiService;

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @Mock
    private PetRepository petRepository;

    @InjectMocks
    private AiChatService aiChatService;

    @Mock
    private VisitRepository visitRepository;

    @InjectMocks
    private VisitService visitService;

    @Mock
    private RecommendationRepository recommendationRepository;

    @InjectMocks
    private RecommendationService recommendationService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testChatPersistenceAndOrchestration() {
        UUID ownerId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        Pet pet = Pet.builder().id(petId).ownerId(ownerId).build();

        AiChatRequest request = AiChatRequest.builder()
                .petId(petId)
                .message("Kedim bugün ne yemeli?")
                .build();

        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));
        when(emergencySafetyService.sanitizePromptInput(anyString())).thenReturn(request.getMessage());
        when(emergencySafetyService.checkEmergency(anyString())).thenReturn(Optional.empty());
        when(petContextService.buildOwnerPetsContext(ownerId, petId)).thenReturn("Kedi Pamuk (2 yaşında)");
        when(geminiService.generateContent(any(), any(), anyString())).thenReturn("Kedinize somonlu yaş mama verebilirsiniz.");

        AiChatResponse response = aiChatService.processChat(ownerId, "owner", request);

        assertNotNull(response);
        assertFalse(response.isEmergency());
        assertNotNull(response.getReply());
        assertTrue(response.getReply().contains("somonlu"));

        // Verify messages saved to database
        verify(chatMessageRepository, times(2)).save(any(ChatMessage.class));
    }

    @Test
    void testGlobalExceptionHandler_GeminiApiException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        GeminiApiException ex = new GeminiApiException("Kota aşıldı", 429);

        ResponseEntity<Map<String, Object>> response = handler.handleGeminiApiException(ex);

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, response.getStatusCode());
        assertTrue(response.getBody().get("message").toString().contains("yoğun"));
    }

    @Test
    void testGlobalExceptionHandler_DataIntegrityViolationException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        org.springframework.dao.DataIntegrityViolationException ex =
                new org.springframework.dao.DataIntegrityViolationException("duplicate key value violates unique constraint");

        ResponseEntity<Map<String, Object>> response = handler.handleDataIntegrityViolation(ex);

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertEquals("CONFLICT", response.getBody().get("error"));
        assertTrue(response.getBody().get("message").toString().contains("bütünlüğü"));
    }

    @Test
    void testVisitService_CreateAndRetrieve() {
        UUID petId = UUID.randomUUID();
        VisitCreateRequest request = VisitCreateRequest.builder()
                .petId(petId)
                .chiefComplaint("Rutin genel kontrol")
                .build();

        Visit savedVisit = Visit.builder()
                .id(UUID.randomUUID())
                .petId(petId)
                .chiefComplaint("Rutin genel kontrol")
                .status("ongoing")
                .build();

        when(visitRepository.save(any(Visit.class))).thenReturn(savedVisit);
        when(visitRepository.findByPetIdOrderByStartedAtDesc(petId)).thenReturn(List.of(savedVisit));

        Visit created = visitService.createVisit(request);
        assertNotNull(created);
        assertEquals("ongoing", created.getStatus());

        List<Visit> list = visitService.getVisitsByPetId(petId);
        assertEquals(1, list.size());
    }

    @Test
    void testRecommendationService_CreateAndRetrieve() {
        UUID visitId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();

        RecommendationCreateRequest request = RecommendationCreateRequest.builder()
                .visitId(visitId)
                .type("mama")
                .description("Tahılsız somonlu mama önerildi")
                .build();

        Recommendation saved = Recommendation.builder()
                .id(UUID.randomUUID())
                .visitId(visitId)
                .type("mama")
                .description("Tahılsız somonlu mama önerildi")
                .build();

        when(visitRepository.findById(visitId)).thenReturn(Optional.of(Visit.builder().id(visitId).status("ongoing").build()));
        when(recommendationRepository.save(any(Recommendation.class))).thenReturn(saved);
        when(recommendationRepository.findByVisitId(visitId)).thenReturn(List.of(saved));

        RecommendationResponse created = recommendationService.createRecommendation(visitId, request, ownerId);
        assertNotNull(created);
        assertEquals("mama", created.getType());

        // removed getRecommendationsByVisitId verification as it is now deleted
    }
}
