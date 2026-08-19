package com.vettrack.api.ai.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiChatResponse {
    private UUID messageId;
    private UUID conversationId;
    private boolean emergency;
    private String reply;
    private String disclaimer;
    private String model;
    private String promptVersion;
    private OffsetDateTime createdAt;

    public static AiChatResponseBuilder builder() {
        return new AiChatResponseBuilder();
    }

    public static class AiChatResponseBuilder {
        private UUID messageId;
        private UUID conversationId;
        private boolean emergency;
        private String reply;
        private String disclaimer;
        private String model;
        private String promptVersion;
        private OffsetDateTime createdAt;

        public AiChatResponseBuilder messageId(UUID messageId) { this.messageId = messageId; return this; }
        public AiChatResponseBuilder conversationId(UUID conversationId) { this.conversationId = conversationId; return this; }
        public AiChatResponseBuilder emergency(boolean emergency) { this.emergency = emergency; return this; }
        public AiChatResponseBuilder reply(String reply) { this.reply = reply; return this; }
        public AiChatResponseBuilder disclaimer(String disclaimer) { this.disclaimer = disclaimer; return this; }
        public AiChatResponseBuilder model(String model) { this.model = model; return this; }
        public AiChatResponseBuilder promptVersion(String promptVersion) { this.promptVersion = promptVersion; return this; }
        public AiChatResponseBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

        public AiChatResponse build() {
            AiChatResponse r = new AiChatResponse();
            r.messageId = this.messageId;
            r.conversationId = this.conversationId;
            r.emergency = this.emergency;
            r.reply = this.reply;
            r.disclaimer = this.disclaimer;
            r.model = this.model;
            r.promptVersion = this.promptVersion;
            r.createdAt = this.createdAt;
            return r;
        }
    }

    public UUID getMessageId() { return messageId; }
    public void setMessageId(UUID messageId) { this.messageId = messageId; }
    public UUID getConversationId() { return conversationId; }
    public void setConversationId(UUID conversationId) { this.conversationId = conversationId; }
    public boolean isEmergency() { return emergency; }
    public void setEmergency(boolean emergency) { this.emergency = emergency; }
    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
    public String getDisclaimer() { return disclaimer; }
    public void setDisclaimer(String disclaimer) { this.disclaimer = disclaimer; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public String getPromptVersion() { return promptVersion; }
    public void setPromptVersion(String promptVersion) { this.promptVersion = promptVersion; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
