package com.vettrack.api.ai;

import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.ChatMessagePersistenceService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatMessagePersistenceServiceTest {

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @InjectMocks
    private ChatMessagePersistenceService persistenceService;

    @Test
    @DisplayName("Benzersiz kısıt ihlali durumunda (DataIntegrityViolationException) var olan kullanıcı mesajını getirmelidir")
    void whenUniqueConstraintViolationOnUserMessage_thenReturnsExistingMessage() {
        UUID ownerId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        String clientMsgId = "client-unique-123";
        ChatMessage existing = ChatMessage.builder()
                .id(UUID.randomUUID())
                .ownerId(ownerId)
                .petId(petId)
                .clientMessageId(clientMsgId)
                .content("Merhaba")
                .role("user")
                .build();

        when(chatMessageRepository.saveAndFlush(any(ChatMessage.class)))
                .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));
        when(chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMsgId))
                .thenReturn(Optional.of(existing));

        ChatMessage result = persistenceService.saveChatMessage(
                UUID.randomUUID(), clientMsgId, ownerId, petId,
                "user", "Merhaba", false, "gemini-2.5-flash",
                "v1.3-security-guardrail", null
        );

        assertNotNull(result);
        assertEquals(existing.getId(), result.getId());
        assertEquals("Merhaba", result.getContent());
    }

    @Test
    @DisplayName("Benzersiz kısıt ihlali durumunda (DataIntegrityViolationException) var olan model mesajını getirmelidir")
    void whenUniqueConstraintViolationOnModelMessage_thenReturnsExistingModelReply() {
        UUID ownerId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        String replyToMsgId = "client-unique-123";
        ChatMessage existingModelReply = ChatMessage.builder()
                .id(UUID.randomUUID())
                .ownerId(ownerId)
                .petId(petId)
                .replyToClientMessageId(replyToMsgId)
                .content("Model yanıtı")
                .role("model")
                .build();

        when(chatMessageRepository.saveAndFlush(any(ChatMessage.class)))
                .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));
        when(chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(ownerId, replyToMsgId, "model"))
                .thenReturn(Optional.of(existingModelReply));

        ChatMessage result = persistenceService.saveChatMessage(
                UUID.randomUUID(), null, ownerId, petId,
                "model", "Model yanıtı", false, "gemini-2.5-flash",
                "v1.3-security-guardrail", replyToMsgId
        );

        assertNotNull(result);
        assertEquals(existingModelReply.getId(), result.getId());
        assertEquals("Model yanıtı", result.getContent());
    }
}
