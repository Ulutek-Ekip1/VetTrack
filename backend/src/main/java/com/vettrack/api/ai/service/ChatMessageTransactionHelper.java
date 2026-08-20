package com.vettrack.api.ai.service;

import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class ChatMessageTransactionHelper {

    private final ChatMessageRepository chatMessageRepository;

    /**
     * Executes the insert in an isolated transaction.
     * If a constraint violation occurs, the exception is allowed to propagate out of this method,
     * enabling Spring's transaction interceptor to cleanly rollback this isolated transaction.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public ChatMessage insertInNewTransaction(ChatMessage message) {
        return chatMessageRepository.saveAndFlush(message);
    }

    /**
     * Reads the existing message by clientMessageId in a clean, read-only transaction.
     */
    @Transactional(readOnly = true, propagation = Propagation.REQUIRES_NEW)
    public Optional<ChatMessage> findExistingByClientMessageId(UUID ownerId, String clientMessageId) {
        return chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMessageId);
    }

    /**
     * Reads the existing model reply by replyToClientMessageId in a clean, read-only transaction.
     */
    @Transactional(readOnly = true, propagation = Propagation.REQUIRES_NEW)
    public Optional<ChatMessage> findExistingByReplyToClientMessageId(UUID ownerId, String replyToClientMessageId) {
        return chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(
                ownerId, replyToClientMessageId, "model"
        );
    }
}
