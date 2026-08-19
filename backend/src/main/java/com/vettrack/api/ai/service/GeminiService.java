package com.vettrack.api.ai.service;

import com.vettrack.api.ai.dto.ChatMessageDto;
import com.vettrack.api.ai.dto.GeminiApiDtos;
import com.vettrack.api.ai.exception.GeminiApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class GeminiService {

    private static final int MAX_HISTORY_TURNS = 10;

    private final RestClient geminiRestClient;

    @Value("${gemini.model:gemini-1.5-flash}")
    private String modelName;

    /**
     * Executes generateContent request against Google Gemini REST API with context truncation and exception handling.
     */
    public String generateContent(String systemInstructionText, List<ChatMessageDto> history, String userMessage) {
        try {
            List<GeminiApiDtos.Content> contents = new ArrayList<>();

            // Context Truncation: Take only the last 10 turns of history
            List<ChatMessageDto> truncatedHistory = history;
            if (history != null && history.size() > MAX_HISTORY_TURNS) {
                truncatedHistory = history.subList(history.size() - MAX_HISTORY_TURNS, history.size());
            }

            if (truncatedHistory != null) {
                for (ChatMessageDto msg : truncatedHistory) {
                    if (msg.getRole() != null && msg.getContent() != null && !msg.getContent().isBlank()) {
                        String role = "user".equalsIgnoreCase(msg.getRole()) ? "user" : "model";
                        contents.add(GeminiApiDtos.Content.builder()
                                .role(role)
                                .parts(Collections.singletonList(GeminiApiDtos.Part.builder().text(msg.getContent()).build()))
                                .build());
                    }
                }
            }

            // Add current user message
            contents.add(GeminiApiDtos.Content.builder()
                    .role("user")
                    .parts(Collections.singletonList(GeminiApiDtos.Part.builder().text(userMessage).build()))
                    .build());

            // Build System Instruction
            GeminiApiDtos.Content systemInstruction = null;
            if (systemInstructionText != null && !systemInstructionText.isBlank()) {
                systemInstruction = GeminiApiDtos.Content.builder()
                        .parts(Collections.singletonList(GeminiApiDtos.Part.builder().text(systemInstructionText).build()))
                        .build();
            }

            GeminiApiDtos.Request requestBody = GeminiApiDtos.Request.builder()
                    .contents(contents)
                    .systemInstruction(systemInstruction)
                    .build();

            String uri = String.format("/v1beta/models/%s:generateContent", modelName);

            GeminiApiDtos.Response apiResponse = geminiRestClient.post()
                    .uri(uri)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody)
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, (request, response) -> {
                        int statusCode = response.getStatusCode().value();
                        log.error("Gemini API error response status: {}", statusCode);
                        if (statusCode == 429) {
                            throw new GeminiApiException("Gemini API kota sınırı aşıldı (429)", 429);
                        }
                        throw new GeminiApiException("Gemini API hatası (" + statusCode + ")", statusCode);
                    })
                    .body(GeminiApiDtos.Response.class);

            if (apiResponse != null && apiResponse.getCandidates() != null && !apiResponse.getCandidates().isEmpty()) {
                GeminiApiDtos.Candidate candidate = apiResponse.getCandidates().get(0);
                if (candidate.getContent() != null && candidate.getContent().getParts() != null && !candidate.getContent().getParts().isEmpty()) {
                    return candidate.getContent().getParts().get(0).getText();
                }
            }

            log.warn("Gemini API returned empty response structure for model: {}", modelName);
            return "Şu anda yanıt üretilemiyor. Lütfen biraz sonra tekrar deneyiniz.";

        } catch (GeminiApiException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error communicating with Gemini REST API model {}: {}", modelName, e.getMessage(), e);
            throw new GeminiApiException("Yapay zeka servisiyle iletişim sırasında beklenmeyen bir hata oluştu: " + e.getMessage());
        }
    }
}
