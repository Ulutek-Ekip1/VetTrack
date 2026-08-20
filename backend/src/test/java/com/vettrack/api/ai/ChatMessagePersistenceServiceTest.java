package com.vettrack.api.ai;

import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.ai.service.ChatMessagePersistenceService;
import com.vettrack.api.ai.service.ChatMessageTransactionHelper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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

    @Mock
    private ChatMessageTransactionHelper transactionHelper;

    private ChatMessagePersistenceService persistenceService;

    @BeforeEach
    void setUp() {
        persistenceService = new ChatMessagePersistenceService(transactionHelper, chatMessageRepository);
    }

    @Test
    @DisplayName("İç transaction'dan DataIntegrityViolationException fırlatıldığında dış katmanda yakalanıp var olan kullanıcı mesajı temiz bir transaction ile okunmalıdır")
    void whenUniqueConstraintViolationOnUserMessage_thenCatchesOutsideAndFetchesExisting() {
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

        when(transactionHelper.insertInNewTransaction(any(ChatMessage.class)))
                .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));
        when(transactionHelper.findExistingByClientMessageId(ownerId, clientMsgId))
                .thenReturn(Optional.of(existing));

        ChatMessage result = persistenceService.saveChatMessage(
                UUID.randomUUID(), clientMsgId, ownerId, petId,
                "user", "Merhaba", false, "gemini-2.5-flash",
                "v1.3-security-guardrail", null
        );

        assertNotNull(result);
        assertEquals(existing.getId(), result.getId());
        assertEquals("Merhaba", result.getContent());
        verify(transactionHelper, times(1)).insertInNewTransaction(any(ChatMessage.class));
        verify(transactionHelper, times(1)).findExistingByClientMessageId(ownerId, clientMsgId);
    }

    @Test
    @DisplayName("İç transaction'dan DataIntegrityViolationException fırlatıldığında model yanıtı temiz bir transaction ile okunmalıdır")
    void whenUniqueConstraintViolationOnModelMessage_thenCatchesOutsideAndFetchesExistingModelReply() {
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

        when(transactionHelper.insertInNewTransaction(any(ChatMessage.class)))
                .thenThrow(new DataIntegrityViolationException("duplicate key value violates unique constraint"));
        when(transactionHelper.findExistingByReplyToClientMessageId(ownerId, replyToMsgId))
                .thenReturn(Optional.of(existingModelReply));

        ChatMessage result = persistenceService.saveChatMessage(
                UUID.randomUUID(), null, ownerId, petId,
                "model", "Model yanıtı", false, "gemini-2.5-flash",
                "v1.3-security-guardrail", replyToMsgId
        );

        assertNotNull(result);
        assertEquals(existingModelReply.getId(), result.getId());
        assertEquals("Model yanıtı", result.getContent());
        verify(transactionHelper, times(1)).insertInNewTransaction(any(ChatMessage.class));
        verify(transactionHelper, times(1)).findExistingByReplyToClientMessageId(ownerId, replyToMsgId);
    }

    @Test
    @DisplayName("ChatMessageTransactionHelper insert ve okuma metodları repository'ye doğru delege etmelidir")
    void testTransactionHelperDelegation() {
        ChatMessageTransactionHelper directHelper = new ChatMessageTransactionHelper(chatMessageRepository);
        ChatMessage msg = ChatMessage.builder().id(UUID.randomUUID()).build();
        when(chatMessageRepository.saveAndFlush(msg)).thenReturn(msg);

        ChatMessage saved = directHelper.insertInNewTransaction(msg);
        assertEquals(msg.getId(), saved.getId());
        verify(chatMessageRepository, times(1)).saveAndFlush(msg);
    }
}
