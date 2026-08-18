package com.vettrack.api.ai;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.dto.AiChatResponse;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.AiChatService;
import com.vettrack.api.ai.service.EmergencySafetyService;
import com.vettrack.api.ai.service.GeminiService;
import com.vettrack.api.ai.service.PetContextService;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

class GeminiServiceMockTest {

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

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testProcessChat_OrchestrationWithMockResponse() {
        UUID ownerId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        Pet testPet = Pet.builder().id(petId).ownerId(ownerId).build();

        AiChatRequest request = AiChatRequest.builder()
                .petId(petId)
                .message("Kedim için somonlu mama mı tavuklu mama mı daha iyidir?")
                .aiConsentGiven(true)
                .build();

        when(petRepository.findById(petId)).thenReturn(Optional.of(testPet));
        when(emergencySafetyService.sanitizePromptInput(anyString())).thenReturn(request.getMessage());
        when(emergencySafetyService.checkEmergency(anyString())).thenReturn(Optional.empty());
        when(petContextService.buildOwnerPetsContext(ownerId, petId)).thenReturn("Pamuk - Kedi (Tekir)");
        when(geminiService.generateContent(any(), any(), anyString()))
                .thenReturn("Somonlu mama tüy sağlığı için omegalar açısından oldukça faydalıdır.");

        AiChatResponse response = aiChatService.processChat(ownerId, "owner", request);

        assertNotNull(response);
        assertFalse(response.isEmergency());
        assertNotNull(response.getReply());
        assertTrue(response.getReply().contains("Somonlu mama"));
        assertNotNull(response.getDisclaimer());
        assertTrue(response.getDisclaimer().contains("YASAL UYARI"));
    }
}