package com.vettrack.api.ai.service;

import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatMessagePersistenceService {

    private final ChatMessageRepository chatMessageRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public ChatMessage saveChatMessage(UUID conversationId, String clientMessageId, UUID ownerId, UUID petId,
                                       String role, String content, boolean emergency, String modelName,
                                       String promptVersion, String replyToClientMessageId) {
        try {
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
            return chatMessageRepository.saveAndFlush(msg);
        } catch (DataIntegrityViolationException dive) {
            log.warn("Unique constraint violation for clientMessageId: {} / replyToClientMessageId: {} / ownerId: {}. Fetching existing record.",
                    clientMessageId, replyToClientMessageId, ownerId);
            if (clientMessageId != null) {
                return chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMessageId).orElse(null);
            }
            if (replyToClientMessageId != null) {
                return chatMessageRepository.findFirstByOwnerIdAndReplyToClientMessageIdAndRoleOrderByCreatedAtAsc(ownerId, replyToClientMessageId, "model").orElse(null);
            }
            return null;
        } catch (Exception e) {
            log.error("Failed to persist chat message for conversation {}: {}", conversationId, e.getMessage());
            return null;
        }
    }
}
