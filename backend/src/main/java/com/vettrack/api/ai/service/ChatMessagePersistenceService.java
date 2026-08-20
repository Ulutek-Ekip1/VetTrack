package com.vettrack.api.ai.service;

import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
public class ChatMessagePersistenceService {

    private final ChatMessageTransactionHelper transactionHelper;
    private final ChatMessageRepository chatMessageRepository;

    @Autowired
    public ChatMessagePersistenceService(
            ChatMessageTransactionHelper transactionHelper,
            ChatMessageRepository chatMessageRepository) {
        this.transactionHelper = transactionHelper != null
                ? transactionHelper
                : new ChatMessageTransactionHelper(chatMessageRepository);
        this.chatMessageRepository = chatMessageRepository;
    }

    public ChatMessagePersistenceService(ChatMessageRepository chatMessageRepository) {
        this(new ChatMessageTransactionHelper(chatMessageRepository), chatMessageRepository);
    }

    /**
     * Saves a chat message idempotently.
     * Note: This method is intentionally NOT annotated with @Transactional so that
     * constraint violations inside insertInNewTransaction roll back their isolated transaction
     * without poisoning or corrupting the caller's execution flow.
     */
    public ChatMessage saveChatMessage(UUID conversationId, String clientMessageId, UUID ownerId, UUID petId,
                                       String role, String content, boolean emergency, String modelName,
                                       String promptVersion, String replyToClientMessageId) {
        ChatMessage msg = ChatMessage.builder()
                .conversationId(conversationId)
                .clientMessageId(clientMessageId)
                .ownerId(ownerId)
                .petId(petId)
                .role(role)
                .content(content)
                .emergency(emergency)
                .model(modelName)
                .promptVersion(promptVersion)
                .replyToClientMessageId(replyToClientMessageId)
                .build();

        try {
            return transactionHelper.insertInNewTransaction(msg);
        } catch (DataIntegrityViolationException dive) {
            log.warn("Unique constraint violation during insert for clientMessageId: {} / replyToClientMessageId: {} / ownerId: {}. Fetching existing record.",
                    clientMessageId, replyToClientMessageId, ownerId);
            return fetchExisting(ownerId, clientMessageId, replyToClientMessageId);
        } catch (Exception e) {
            log.error("Failed to persist chat message for conversation {}: {}", conversationId, e.getMessage());
            return null;
        }
    }

    private ChatMessage fetchExisting(UUID ownerId, String clientMessageId, String replyToClientMessageId) {
        try {
            if (clientMessageId != null) {
                return transactionHelper.findExistingByClientMessageId(ownerId, clientMessageId).orElse(null);
            }
            if (replyToClientMessageId != null) {
                return transactionHelper.findExistingByReplyToClientMessageId(ownerId, replyToClientMessageId).orElse(null);
            }
        } catch (Exception e) {
            log.error("Failed to fetch existing message for ownerId {}: {}", ownerId, e.getMessage());
        }
        return null;
    }
}
