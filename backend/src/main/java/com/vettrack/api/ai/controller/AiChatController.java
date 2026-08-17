package com.vettrack.api.ai.controller;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.dto.AiChatResponse;
import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.service.AiChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping({"/api/v1/ai", "/api/v1/ai/chat", "/api/ai/chat", "/ai/chat"})
@RequiredArgsConstructor
@Tag(name = "AI Chat Asistanı", description = "Google Gemini tabanlı veteriner yapay zeka sohbet ve danışmanlık API'si")
public class AiChatController {

    private final AiChatService aiChatService;

    @PostMapping({"", "/message"})
    @Operation(summary = "Yapay Zeka Asistanı İle Sohbet Et", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Yapay zeka yanıtı başarıyla üretildi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz sohbet isteği"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim / Geçersiz JWT"),
        @ApiResponse(responseCode = "403", description = "Erişim yetkisi yok (Pet veya Konuşma sahipliği hatası)"),
        @ApiResponse(responseCode = "409", description = "Idempotency anahtarı çakışması (Farklı içerikle aynı clientMessageId)"),
        @ApiResponse(responseCode = "429", description = "Çok fazla istek (Rate limit aşıldı)"),
        @ApiResponse(responseCode = "503", description = "Yapay zeka servisi geçici olarak kullanılamıyor")
    })
    public ResponseEntity<AiChatResponse> chat(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody AiChatRequest request
    ) {
        UUID ownerId = jwt != null && jwt.getSubject() != null ? UUID.fromString(jwt.getSubject()) : null;
        String role = jwt != null ? jwt.getClaimAsString("role") : null;

        AiChatResponse response = aiChatService.processChat(ownerId, role, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/history")
    @Operation(summary = "Tüm Sohbet Geçmişini Sayfalamalı Getir", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<ChatMessage>> getGeneralChatHistory(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int limit
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(aiChatService.getChatHistory(ownerId, null, page, limit));
    }

    @GetMapping("/history/{petId}")
    @Operation(summary = "Pet Bazlı Sohbet Geçmişini Sayfalamalı Getir", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<List<ChatMessage>> getPetChatHistory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID petId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int limit
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(aiChatService.getChatHistory(ownerId, petId, page, limit));
    }

    @DeleteMapping("/history/conversation/{conversationId}")
    @Operation(summary = "Belirli Bir Konuşma Oturumunu Sil (KVKK)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> deleteConversation(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID conversationId
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        aiChatService.deleteConversation(ownerId, conversationId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/history")
    @Operation(summary = "Tüm Sohbet Geçmişini Sil (KVKK Unutulma Hakkı)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> deleteAllChatHistory(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        aiChatService.deleteUserHistory(ownerId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping({"/messages/{id}", "/chat/messages/{id}"})
    @Operation(summary = "Tekil Sohbet Mesajını Sil", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Mesaj başarıyla silindi"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "403", description = "Bu mesajı silme yetkiniz yok"),
        @ApiResponse(responseCode = "404", description = "Mesaj bulunamadı")
    })
    public ResponseEntity<Void> deleteMessage(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        aiChatService.deleteSingleMessage(ownerId, id);
        return ResponseEntity.noContent().build();
    }
}