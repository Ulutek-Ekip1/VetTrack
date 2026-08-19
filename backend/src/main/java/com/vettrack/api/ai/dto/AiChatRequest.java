package com.vettrack.api.ai.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiChatRequest {

    private UUID conversationId;
    private String clientMessageId;
    private UUID petId;

    @NotBlank(message = "Mesaj boş olamaz.")
    private String message;

    @Builder.Default
    private Boolean aiConsentGiven = true;

    @Builder.Default
    private List<ChatMessageDto> history = new ArrayList<>();

    public static AiChatRequestBuilder builder() {
        return new AiChatRequestBuilder();
    }

    public static class AiChatRequestBuilder {
        private UUID conversationId;
        private String clientMessageId;
        private UUID petId;
        private String message;
        private Boolean aiConsentGiven = true;
        private List<ChatMessageDto> history = new ArrayList<>();

        public AiChatRequestBuilder conversationId(UUID conversationId) { this.conversationId = conversationId; return this; }
        public AiChatRequestBuilder clientMessageId(String clientMessageId) { this.clientMessageId = clientMessageId; return this; }
        public AiChatRequestBuilder petId(UUID petId) { this.petId = petId; return this; }
        public AiChatRequestBuilder message(String message) { this.message = message; return this; }
        public AiChatRequestBuilder aiConsentGiven(Boolean aiConsentGiven) { this.aiConsentGiven = aiConsentGiven; return this; }
        public AiChatRequestBuilder history(List<ChatMessageDto> history) { this.history = history; return this; }

        public AiChatRequest build() {
            AiChatRequest r = new AiChatRequest();
            r.conversationId = this.conversationId;
            r.clientMessageId = this.clientMessageId;
            r.petId = this.petId;
            r.message = this.message;
            r.aiConsentGiven = this.aiConsentGiven;
            r.history = this.history;
            return r;
        }
    }

    public UUID getConversationId() { return conversationId; }
    public void setConversationId(UUID conversationId) { this.conversationId = conversationId; }
    public String getClientMessageId() { return clientMessageId; }
    public void setClientMessageId(String clientMessageId) { this.clientMessageId = clientMessageId; }
    public UUID getPetId() { return petId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Boolean getAiConsentGiven() { return aiConsentGiven; }
    public void setAiConsentGiven(Boolean aiConsentGiven) { this.aiConsentGiven = aiConsentGiven; }
    public List<ChatMessageDto> getHistory() { return history; }
    public void setHistory(List<ChatMessageDto> history) { this.history = history; }
}