package com.vettrack.api.ai.repository;

import com.vettrack.api.ai.entity.ChatMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {

    Optional<ChatMessage> findByOwnerIdAndClientMessageId(UUID ownerId, String clientMessageId);

    Optional<ChatMessage> findFirstByConversationId(UUID conversationId);

    List<ChatMessage> findByOwnerIdAndConversationIdOrderByCreatedAtAsc(UUID ownerId, UUID conversationId);

    Page<ChatMessage> findByOwnerIdAndPetIdOrderByCreatedAtAsc(UUID ownerId, UUID petId, Pageable pageable);

    Page<ChatMessage> findByOwnerIdOrderByCreatedAtAsc(UUID ownerId, Pageable pageable);

    List<ChatMessage> findByOwnerIdAndPetIdOrderByCreatedAtAsc(UUID ownerId, UUID petId);

    List<ChatMessage> findByOwnerIdOrderByCreatedAtAsc(UUID ownerId);

    List<ChatMessage> findTop10ByOwnerIdAndPetIdOrderByCreatedAtDesc(UUID ownerId, UUID petId);

    List<ChatMessage> findTop10ByOwnerIdOrderByCreatedAtDesc(UUID ownerId);

    void deleteByConversationIdAndOwnerId(UUID conversationId, UUID ownerId);

    void deleteByOwnerId(UUID ownerId);
}
