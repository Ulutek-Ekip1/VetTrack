package com.vettrack.api.ai;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.AiChatService;
import com.vettrack.api.ai.service.ChatMessagePersistenceService;
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
import org.mockito.Spy;
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

    @Spy
    @InjectMocks
    private ChatMessagePersistenceService chatMessagePersistenceService;

    @InjectMocks
    private AiChatService aiChatService;

    private UUID ownerId;

    @BeforeEach
    void setUp() {
        ownerId = UUID.randomUUID();
    }

    @Test
    @DisplayName("aiConsentGiven açıkça false olduğunda AI_CONSENT_REQUIRED fırlatmalıdır")
    void testConsentRequiredWhenExplicitlyFalse() {
        AiChatRequest requestFalse = AiChatRequest.builder()
                .message("Kedim tüy döküyor")
                .aiConsentGiven(false)
                .build();

        ApiException exFalse = assertThrows(ApiException.class, () ->
                aiChatService.processChat(ownerId, "owner", requestFalse)
        );
        assertEquals(ErrorCode.AI_CONSENT_REQUIRED, exFalse.getErrorCode());
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

    @Test
    @DisplayName("P2: 50. mesaj kaydedildikten sonra retry yapıldığında günlük limit aşılmış olsa bile 429 atmadan yanıt üretmelidir")
    void testIdempotencyRetry_WhenDailyLimitReached_AllowsRetryOfExistingMessage() {
        String clientMsgId = "msg-limit-retry-50";
        UUID conversationId = UUID.randomUUID();
        AiChatRequest request = AiChatRequest.builder()
                .message("50. mesajım")
                .clientMessageId(clientMsgId)
                .aiConsentGiven(true)
                .build();

        com.vettrack.api.ai.entity.ChatMessage existingUserMsg = com.vettrack.api.ai.entity.ChatMessage.builder()
                .id(UUID.randomUUID())
                .conversationId(conversationId)
                .ownerId(ownerId)
                .clientMessageId(clientMsgId)
                .content("50. mesajım")
                .role("user")
                .build();

        when(emergencySafetyService.sanitizePromptInput("50. mesajım")).thenReturn("50. mesajım");
        when(chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMsgId)).thenReturn(java.util.Optional.of(existingUserMsg));
        when(chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(ownerId, clientMsgId, "model"))
                .thenReturn(java.util.Optional.empty());
        when(chatMessageRepository.findFirstByConversationIdAndRoleAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(eq(conversationId), eq("model"), any()))
                .thenReturn(java.util.Optional.empty());
        when(emergencySafetyService.checkEmergency("50. mesajım")).thenReturn(java.util.Optional.empty());
        when(petContextService.buildOwnerPetsContext(ownerId, null)).thenReturn("Pet context");
        when(geminiService.generateContent(any(), any(), eq("50. mesajım"))).thenReturn("50. mesaj yanıtı");

        com.vettrack.api.ai.dto.AiChatResponse response = aiChatService.processChat(ownerId, "owner", request);

        org.junit.jupiter.api.Assertions.assertNotNull(response);
        assertEquals("50. mesaj yanıtı", response.getReply());
        // Verify quota count method was NEVER called for retry message
        org.mockito.Mockito.verify(chatMessageRepository, org.mockito.Mockito.never())
                .countByOwnerIdAndRoleAndCreatedAtGreaterThanEqual(eq(ownerId), eq("user"), any());
    }

    @Test
    @DisplayName("P1: Daha önce model yanıtı üretilmiş mesaj için tekrar çağrıldığında Gemini çağrılmadan önbellekten dönmelidir")
    void testIdempotency_CachedReplyReturnedWithoutCallingGemini() {
        String clientMsgId = "msg-cached-123";
        UUID conversationId = UUID.randomUUID();
        UUID modelMsgId = UUID.randomUUID();
        AiChatRequest request = AiChatRequest.builder()
                .message("Önbellek testi")
                .clientMessageId(clientMsgId)
                .aiConsentGiven(true)
                .build();

        com.vettrack.api.ai.entity.ChatMessage existingUserMsg = com.vettrack.api.ai.entity.ChatMessage.builder()
                .id(UUID.randomUUID())
                .conversationId(conversationId)
                .ownerId(ownerId)
                .clientMessageId(clientMsgId)
                .content("Önbellek testi")
                .role("user")
                .build();

        com.vettrack.api.ai.entity.ChatMessage existingModelMsg = com.vettrack.api.ai.entity.ChatMessage.builder()
                .id(modelMsgId)
                .conversationId(conversationId)
                .ownerId(ownerId)
                .replyToClientMessageId(clientMsgId)
                .content("Önbellekteki AI yanıtı")
                .role("model")
                .emergency(false)
                .model("gemini-2.5-flash")
                .promptVersion("v1.3-security-guardrail")
                .createdAt(OffsetDateTime.now())
                .build();

        when(emergencySafetyService.sanitizePromptInput("Önbellek testi")).thenReturn("Önbellek testi");
        when(chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMsgId)).thenReturn(java.util.Optional.of(existingUserMsg));
        when(chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(ownerId, clientMsgId, "model"))
                .thenReturn(java.util.Optional.of(existingModelMsg));

        com.vettrack.api.ai.dto.AiChatResponse response = aiChatService.processChat(ownerId, "owner", request);

        org.junit.jupiter.api.Assertions.assertNotNull(response);
        assertEquals("Önbellekteki AI yanıtı", response.getReply());
        assertEquals(modelMsgId, response.getMessageId());
        // Verify Gemini service was never called
        org.mockito.Mockito.verify(geminiService, org.mockito.Mockito.never()).generateContent(any(), any(), any());
    }
}