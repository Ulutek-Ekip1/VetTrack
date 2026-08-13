package com.vettrack.api.ai.service;

import com.vettrack.api.ai.dto.AiChatRequest;
import com.vettrack.api.ai.dto.AiChatResponse;
import com.vettrack.api.ai.dto.ChatMessageDto;
import com.vettrack.api.ai.entity.ChatMessage;
import com.vettrack.api.ai.exception.IdempotencyKeyReusedException;
import com.vettrack.api.ai.repository.ChatMessageRepository;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiChatService {

    public static final String PROMPT_VERSION = "v1.2-mvp";
    public static final String STANDARD_DISCLAIMER =
            "YASAL UYARI: Bu yapay zeka asistanı tarafından verilen bilgiler yalnızca genel rehberlik amaçlıdır. Klinik teşhis veya reçeteli tedavi yerine geçmez. Lütfen kesin tanı için veteriner hekiminize başvurunuz.";

    private final EmergencySafetyService emergencySafetyService;
    private final PetContextService petContextService;
    private final GeminiService geminiService;
    private final ChatMessageRepository chatMessageRepository;
    private final PetRepository petRepository;

    @Value("${gemini.model:gemini-2.5-flash}")
    private String modelName;

    @Transactional
    public AiChatResponse processChat(UUID ownerId, String userRole, AiChatRequest request) {
        long startTime = System.currentTimeMillis();
        boolean isStaff = isStaffRole(userRole);

        // 1. Pet Ownership Check
        if (request.getPetId() != null && ownerId != null) {
            Optional<Pet> petOpt = petRepository.findById(request.getPetId());
            if (petOpt.isPresent() && !isStaff && !petOpt.get().getOwnerId().equals(ownerId)) {
                throw new AccessDeniedException("Bu hayvana ait sohbet başlatma erişim yetkiniz yoktur.");
            }
        }

        // 2. Conversation Ownership & Pet Integrity Check
        if (request.getConversationId() != null && ownerId != null) {
            Optional<ChatMessage> firstMsgOpt = chatMessageRepository.findFirstByConversationId(request.getConversationId());
            if (firstMsgOpt.isPresent()) {
                ChatMessage firstMsg = firstMsgOpt.get();
                if (!isStaff && !firstMsg.getOwnerId().equals(ownerId)) {
                    throw new AccessDeniedException("Bu konuşma oturumuna erişim yetkiniz yoktur.");
                }
                if (request.getPetId() != null && firstMsg.getPetId() != null && !Objects.equals(request.getPetId(), firstMsg.getPetId())) {
                    throw new AccessDeniedException("Konuşma oturumu ve petId uyuşmamaktadır.");
                }
            }
        }

        String sanitizedMessage = emergencySafetyService.sanitizePromptInput(request.getMessage());

        // 3. Idempotency Check & Reuse Validation (409 Conflict check)
        if (ownerId != null && request.getClientMessageId() != null && !request.getClientMessageId().isBlank()) {
            Optional<ChatMessage> existingMsg = chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, request.getClientMessageId());
            if (existingMsg.isPresent()) {
                ChatMessage msg = existingMsg.get();
                if (!sanitizedMessage.equals(msg.getContent()) || !Objects.equals(request.getPetId(), msg.getPetId())) {
                    throw new IdempotencyKeyReusedException("Aynı clientMessageId farklı istek içeriği veya petId ile tekrar kullanılamaz.");
                }
                log.info("Idempotent request hit for clientMessageId: {}. Fetching cached AI assistant response.", request.getClientMessageId());

                Optional<ChatMessage> assistantMsgOpt = chatMessageRepository.findFirstByConversationIdAndRoleAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(msg.getConversationId(), "model", msg.getCreatedAt());
                ChatMessage respMsg = assistantMsgOpt.orElse(msg);

                return AiChatResponse.builder()
                        .messageId(respMsg.getId())
                        .conversationId(msg.getConversationId())
                        .emergency(Boolean.TRUE.equals(respMsg.getEmergency()))
                        .reply(respMsg.getContent())
                        .disclaimer(STANDARD_DISCLAIMER)
                        .model(respMsg.getModel())
                        .promptVersion(respMsg.getPromptVersion())
                        .createdAt(respMsg.getCreatedAt())
                        .build();
            }
        }

        UUID conversationId = request.getConversationId() != null ? request.getConversationId() : UUID.randomUUID();

        // 4. Save user message to database (User messages use clientMessageId)
        if (ownerId != null) {
            saveChatMessage(conversationId, request.getClientMessageId(), ownerId, request.getPetId(), "user", sanitizedMessage, false);
        }

        // 5. Deterministik Acil Durum Kontrolü (Gemini API bypass)
        Optional<AiChatResponse> emergencyResponse = emergencySafetyService.checkEmergency(sanitizedMessage);
        if (emergencyResponse.isPresent()) {
            AiChatResponse resp = emergencyResponse.get();
            resp.setConversationId(conversationId);
            resp.setModel(modelName);

            if (ownerId != null) {
                // Assistant messages ALWAYS pass clientMessageId = NULL
                ChatMessage savedModelMsg = saveChatMessage(conversationId, null, ownerId, request.getPetId(), "model", resp.getReply(), true);
                if (savedModelMsg != null) {
                    resp.setMessageId(savedModelMsg.getId());
                    resp.setCreatedAt(savedModelMsg.getCreatedAt());
                }
            }
            log.info("Emergency bypass triggered for conversation: {} (duration: {}ms)", conversationId, System.currentTimeMillis() - startTime);
            return resp;
        }

        // 6. Security Hardening: Ignore client-provided history & build strictly from server DB records
        List<ChatMessageDto> history = getRecentHistoryFromDb(ownerId, request.getPetId());

        // 7. Dinamik Evcil Hayvan Tıbbi Bağlamı Derleme
        String petContext = petContextService.buildOwnerPetsContext(ownerId, request.getPetId());

        String systemInstruction = String.format(
                "Sen VetTrack uygulaması bünyesinde hizmet veren interaktif bir Veteriner Asistanı Chatbot'usun.\n" +
                "Görevin: Kullanıcıların evcil hayvanları (kedi, köpek vb.) hakkında sordukları sorulara samimi, anlaşılır ve yapıcı yanıtlar vermektir.\n\n" +
                "<system_context>\n%s\n</system_context>\n\n" +
                "CHATBOT VE MVP KURALLARI:\n" +
                "1. Sohbet Tarzı: Kullanıcı ile doğal, empatik ve interaktif bir sohbet sürdür. Sorularına doğrudan yanıt ver.\n" +
                "2. Güvenli Öneriler: Kedinin/evcil hayvanın durumuna ve tıbbi geçmişine göre basit, evde uygulanabilir, risk oluşturmayacak pratik bakım, beslenme, tüy bakımı, su tüketimi ve rahatlatma önerileri sun.\n" +
                "3. Reçete/Teşhis Sınırı: Kesin klinik teşhis koyma, tıbbi ilaç veya dozaj önerme. Ciddi durumlarda veteriner hekim muayenesini tavsiye et.\n" +
                "4. Kişiselleştirme: Hayvanın adı, türü, ırkı veya bilinen aşı/tedavi geçmişi varsa yanıtını bu bilgilere göre özelleştir.",
                petContext
        );

        // 8. Gemini REST API Çağrısı
        String aiReply = geminiService.generateContent(systemInstruction, history, sanitizedMessage);

        // 9. Save AI reply to database (Assistant messages ALWAYS pass clientMessageId = NULL)
        ChatMessage savedModelMsg = null;
        if (ownerId != null) {
            savedModelMsg = saveChatMessage(conversationId, null, ownerId, request.getPetId(), "model", aiReply, false);
        }

        long duration = System.currentTimeMillis() - startTime;
        log.info("AI Chat response generated successfully for conversation: {} using model: {} (latency: {}ms)", conversationId, modelName, duration);

        UUID replyMessageId = savedModelMsg != null ? savedModelMsg.getId() : UUID.randomUUID();
        OffsetDateTime createdAt = savedModelMsg != null ? savedModelMsg.getCreatedAt() : OffsetDateTime.now();

        return AiChatResponse.builder()
                .messageId(replyMessageId)
                .conversationId(conversationId)
                .emergency(false)
                .reply(aiReply)
                .disclaimer(STANDARD_DISCLAIMER)
                .model(modelName)
                .promptVersion(PROMPT_VERSION)
                .createdAt(createdAt)
                .build();
    }

    @Transactional(readOnly = true)
    public List<ChatMessage> getChatHistory(UUID ownerId, UUID petId, int page, int limit) {
        PageRequest pageable = PageRequest.of(Math.max(0, page), Math.min(100, Math.max(1, limit)));
        Page<ChatMessage> pageResult;
        if (petId != null) {
            pageResult = chatMessageRepository.findByOwnerIdAndPetIdOrderByCreatedAtAsc(ownerId, petId, pageable);
        } else {
            pageResult = chatMessageRepository.findByOwnerIdOrderByCreatedAtAsc(ownerId, pageable);
        }
        return pageResult.getContent();
    }

    @Transactional
    public void deleteConversation(UUID ownerId, UUID conversationId) {
        chatMessageRepository.deleteByConversationIdAndOwnerId(conversationId, ownerId);
        log.info("Conversation history deleted for conversationId: {} by ownerId: {}", conversationId, ownerId);
    }

    @Transactional
    public void deleteUserHistory(UUID ownerId) {
        chatMessageRepository.deleteByOwnerId(ownerId);
        log.info("All chat history deleted for ownerId: {}", ownerId);
    }

    private boolean isStaffRole(String role) {
        if (role == null) return false;
        String lowerRole = role.toLowerCase();
        return lowerRole.contains("vet_staff") || lowerRole.contains("admin");
    }

    private ChatMessage saveChatMessage(UUID conversationId, String clientMessageId, UUID ownerId, UUID petId, String role, String content, boolean emergency) {
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
                    .promptVersion(PROMPT_VERSION)
                    .build();
            return chatMessageRepository.save(msg);
        } catch (DataIntegrityViolationException dive) {
            log.warn("Unique constraint violation for clientMessageId: {} / ownerId: {}. Fetching existing record.", clientMessageId, ownerId);
            if (clientMessageId != null) {
                return chatMessageRepository.findByOwnerIdAndClientMessageId(ownerId, clientMessageId).orElse(null);
            }
            return null;
        } catch (Exception e) {
            log.error("Failed to persist chat message for conversation {}: {}", conversationId, e.getMessage());
            return null;
        }
    }

    private List<ChatMessageDto> getRecentHistoryFromDb(UUID ownerId, UUID petId) {
        if (ownerId == null) return new ArrayList<>();

        List<ChatMessage> dbMessages;
        if (petId != null) {
            dbMessages = chatMessageRepository.findTop10ByOwnerIdAndPetIdOrderByCreatedAtDesc(ownerId, petId);
        } else {
            dbMessages = chatMessageRepository.findTop10ByOwnerIdOrderByCreatedAtDesc(ownerId);
        }

        List<ChatMessage> sorted = new ArrayList<>(dbMessages);
        java.util.Collections.reverse(sorted);

        return sorted.stream()
                .map(m -> ChatMessageDto.builder()
                        .role(m.getRole())
                        .content(m.getContent())
                        .build())
                .collect(Collectors.toList());
    }
}
