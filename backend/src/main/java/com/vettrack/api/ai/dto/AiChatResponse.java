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
}
