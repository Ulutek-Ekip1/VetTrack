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
}
