package com.vettrack.api.ai.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "conversation_id")
    private UUID conversationId;

    @Column(name = "client_message_id", length = 100)
    private String clientMessageId;

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Column(name = "pet_id")
    private UUID petId;

    @Column(nullable = false, length = 20)
    private String role; // "user" or "model"

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "is_emergency")
    @Builder.Default
    private Boolean emergency = false;

    @Column(name = "model_name", length = 50)
    private String model;

    @Column(name = "prompt_version", length = 20)
    private String promptVersion;

    @Column(name = "reply_to_client_message_id", length = 100)
    private String replyToClientMessageId;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = OffsetDateTime.now();
        }
    }
}
