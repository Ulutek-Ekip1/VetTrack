package com.vettrack.api.ai;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.AiChatService;
import com.vettrack.api.ai.service.EmergencySafetyService;
import com.vettrack.api.ai.service.GeminiService;
import com.vettrack.api.ai.service.PetContextService;
import com.vettrack.api.common.exception.ApiException;
import com.vettrack.api.common.exception.ErrorCode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AiChatServiceTest {

    @Mock
    private EmergencySafetyService emergencySafetyService;

    @Mock
    private PetContextService petContextService;

    @Mock
    private GeminiService geminiService;

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @InjectMocks
    private AiChatService aiChatService;

    private UUID ownerId;

    @BeforeEach
    void setUp() {
        ownerId = UUID.randomUUID();
    }

    @Test
    @DisplayName("aiConsentGiven false veya null olduğunda AI_CONSENT_REQUIRED fırlatmalıdır")
    void testConsentRequiredWhenFalseOrNull() {
        AiChatRequest requestFalse = AiChatRequest.builder()
                .message("Kedim tüy döküyor")
                .aiConsentGiven(false)
                .build();

        ApiException exFalse = assertThrows(ApiException.class, () ->
                aiChatService.processChat(ownerId, "owner", requestFalse)
        );
        assertEquals(ErrorCode.AI_CONSENT_REQUIRED, exFalse.getErrorCode());

        AiChatRequest requestNull = AiChatRequest.builder()
                .message("Kedim tüy döküyor")
                .aiConsentGiven(null)
                .build();

        ApiException exNull = assertThrows(ApiException.class, () ->
                aiChatService.processChat(ownerId, "owner", requestNull)
        );
        assertEquals(ErrorCode.AI_CONSENT_REQUIRED, exNull.getErrorCode());
    }

    @Test
    @DisplayName("Son 24 saatte 50 mesaj limiti aşıldığında TOO_MANY_REQUESTS fırlatmalıdır")
    void testRateLimitExceeded() {
        AiChatRequest request = AiChatRequest.builder()
                .message("Merhaba")
                .aiConsentGiven(true)
                .build();

        when(chatMessageRepository.countByOwnerIdAndRoleAndCreatedAtGreaterThanEqual(
                eq(ownerId), eq("user"), any(OffsetDateTime.class))
        ).thenReturn(50L);

        ApiException ex = assertThrows(ApiException.class, () ->
                aiChatService.processChat(ownerId, "owner", request)
        );
        assertEquals(ErrorCode.TOO_MANY_REQUESTS, ex.getErrorCode());
    }

    @Test
    @DisplayName("Aynı clientMessageId farklı içerikle tekrar gönderildiğinde IdempotencyKeyReusedException (409) fırlatmalıdır")
    void testIdempotencyConflict_DifferentMessage() {
        String clientMsgId = "msg-123";
        AiChatRequest request = AiChatRequest.builder()
                .message("Yeni farklı mesaj")
                .clientMessageId(clientMsgId)
                .aiConsentGiven(true)
                .build();

        com.vettrack.api.ai.entity.ChatMessage existing = com.vettrack.api.ai.entity.ChatMessage.builder()
                .id(UUID.randomUUID())
                .ownerId(ownerId)
                .clientMessageId(clientMsgId)
                .content("Eski mesaj")
                .role("user")
                .build();

        when(emergencySafetyService.sanitizePromptInput("Yeni farklı mesaj")).thenReturn("Yeni farklı mesaj");
        when(chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMsgId)).thenReturn(java.util.Optional.of(existing));

        assertThrows(com.vettrack.api.ai.exception.IdempotencyKeyReusedException.class, () ->
                aiChatService.processChat(ownerId, "owner", request)
        );
    }

    @Test
    @DisplayName("Aynı clientMessageId ile retry yapıldığında ve model yanıtı yoksa 409 fırlatmadan yanıt üretmelidir")
    void testIdempotencyRetry_GeneratesAssistantResponse() {
        String clientMsgId = "msg-retry-123";
        UUID conversationId = UUID.randomUUID();
        AiChatRequest request = AiChatRequest.builder()
                .message("Kedi aşı takvimi")
                .clientMessageId(clientMsgId)
                .aiConsentGiven(true)
                .build();

        com.vettrack.api.ai.entity.ChatMessage existingUserMsg = com.vettrack.api.ai.entity.ChatMessage.builder()
                .id(UUID.randomUUID())
                .conversationId(conversationId)
                .ownerId(ownerId)
                .clientMessageId(clientMsgId)
                .content("Kedi aşı takvimi")
                .role("user")
                .build();

        when(emergencySafetyService.sanitizePromptInput("Kedi aşı takvimi")).thenReturn("Kedi aşı takvimi");
        when(chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMsgId)).thenReturn(java.util.Optional.of(existingUserMsg));
        when(chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(ownerId, clientMsgId, "model"))
                .thenReturn(java.util.Optional.empty());
        when(chatMessageRepository.findFirstByConversationIdAndRoleAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(eq(conversationId), eq("model"), any()))
                .thenReturn(java.util.Optional.empty());
        when(emergencySafetyService.checkEmergency("Kedi aşı takvimi")).thenReturn(java.util.Optional.empty());
        when(petContextService.buildOwnerPetsContext(ownerId, null)).thenReturn("Pet context");
        when(geminiService.generateContent(any(), any(), eq("Kedi aşı takvimi"))).thenReturn("Aşı takvimi yanıtı");

        com.vettrack.api.ai.dto.AiChatResponse response = aiChatService.processChat(ownerId, "owner", request);

        org.junit.jupiter.api.Assertions.assertNotNull(response);
        assertEquals("Aşı takvimi yanıtı", response.getReply());
        assertEquals(conversationId, response.getConversationId());
    }
}