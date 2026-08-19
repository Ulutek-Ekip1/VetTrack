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

    public static ChatMessageBuilder builder() {
        return new ChatMessageBuilder();
    }

    public static class ChatMessageBuilder {
        private UUID id;
        private UUID conversationId;
        private String clientMessageId;
        private UUID ownerId;
        private UUID petId;
        private String role;
        private String content;
        private Boolean emergency = false;
        private String model;
        private String promptVersion;
        private String replyToClientMessageId;
        private OffsetDateTime createdAt;

        public ChatMessageBuilder id(UUID id) { this.id = id; return this; }
        public ChatMessageBuilder conversationId(UUID conversationId) { this.conversationId = conversationId; return this; }
        public ChatMessageBuilder clientMessageId(String clientMessageId) { this.clientMessageId = clientMessageId; return this; }
        public ChatMessageBuilder ownerId(UUID ownerId) { this.ownerId = ownerId; return this; }
        public ChatMessageBuilder petId(UUID petId) { this.petId = petId; return this; }
        public ChatMessageBuilder role(String role) { this.role = role; return this; }
        public ChatMessageBuilder content(String content) { this.content = content; return this; }
        public ChatMessageBuilder emergency(Boolean emergency) { this.emergency = emergency; return this; }
        public ChatMessageBuilder model(String model) { this.model = model; return this; }
        public ChatMessageBuilder promptVersion(String promptVersion) { this.promptVersion = promptVersion; return this; }
        public ChatMessageBuilder replyToClientMessageId(String replyToClientMessageId) { this.replyToClientMessageId = replyToClientMessageId; return this; }
        public ChatMessageBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

        public ChatMessage build() {
            ChatMessage c = new ChatMessage();
            c.id = this.id;
            c.conversationId = this.conversationId;
            c.clientMessageId = this.clientMessageId;
            c.ownerId = this.ownerId;
            c.petId = this.petId;
            c.role = this.role;
            c.content = this.content;
            c.emergency = this.emergency;
            c.model = this.model;
            c.promptVersion = this.promptVersion;
            c.replyToClientMessageId = this.replyToClientMessageId;
            c.createdAt = this.createdAt;
            return c;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getConversationId() { return conversationId; }
    public void setConversationId(UUID conversationId) { this.conversationId = conversationId; }
    public String getClientMessageId() { return clientMessageId; }
    public void setClientMessageId(String clientMessageId) { this.clientMessageId = clientMessageId; }
    public UUID getOwnerId() { return ownerId; }
    public void setOwnerId(UUID ownerId) { this.ownerId = ownerId; }
    public UUID getPetId() { return petId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Boolean getEmergency() { return emergency; }
    public void setEmergency(Boolean emergency) { this.emergency = emergency; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public String getPromptVersion() { return promptVersion; }
    public void setPromptVersion(String promptVersion) { this.promptVersion = promptVersion; }
    public String getReplyToClientMessageId() { return replyToClientMessageId; }
    public void setReplyToClientMessageId(String replyToClientMessageId) { this.replyToClientMessageId = replyToClientMessageId; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
