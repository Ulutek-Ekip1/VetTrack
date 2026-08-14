package com.vettrack.api.ai.service;

import com.vettrack.api.ai.dto.AiChatResponse;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class EmergencySafetyService {

    public static final String RULE_VERSION = "v1.2-emergency";

    public static final String EMERGENCY_DISCLAIMER =
            "ACİL DURUM UYARISI: Tespit edilen semptomlar hayati tehlike oluşturabilir. Yapay zeka tavsiyesi beklenmeden derhal en yakın acil veteriner kliniğine başvurulmalıdır.";

    private static final List<String> RESPIRATORY_KEYWORDS = Arrays.asList(
            "nefes alamıyor", "boğuluyor", "mavi dil", "soluk alamıyor", "solunumu durdu", "nefessiz", "morarma"
    );

    private static final List<String> TOXICOLOGY_KEYWORDS = Arrays.asList(
            "çamaşır suyu içti", "fare zehiri", "çikolata yedi", "zehirlendi", "zehir içti", "deterjan yuttu", "ilaç yuttu"
    );

    private static final List<String> TRAUMA_KEYWORDS = Arrays.asList(
            "durmayan kanama", "araba çarptı", "felç", "bilincini kaybetme", "yüksekten düşme", "kan kusuyor", "aşırı kanama", "bayıldı"
    );

    private static final List<String> PROMPT_INJECTION_KEYWORDS = Arrays.asList(
            "önceki talimatları yok say", "ignore previous instructions", "system prompt", "act as developer", "bütün kuralları unut"
    );

    /**
     * Evaluates message against safety matrix in sub-5ms.
     * Returns Optional containing emergency response if critical symptom is matched, empty otherwise.
     */
    public Optional<AiChatResponse> checkEmergency(String message) {
        if (message == null || message.isBlank()) {
            return Optional.empty();
        }

        String lowerMessage = message.toLowerCase(java.util.Locale.forLanguageTag("tr-TR"));

        boolean isRespiratory = RESPIRATORY_KEYWORDS.stream().anyMatch(lowerMessage::contains);
        boolean isToxicology = TOXICOLOGY_KEYWORDS.stream().anyMatch(lowerMessage::contains);
        boolean isTrauma = TRAUMA_KEYWORDS.stream().anyMatch(lowerMessage::contains);

        if (isRespiratory || isToxicology || isTrauma) {
            String emergencyType = isRespiratory ? "SOLUNUM KRİZİ" : (isToxicology ? "ZEHİRLENME ŞÜPHESİ" : "TRAVMA / ŞİDDETLİ KANAMA");

            String reply = String.format(
                    "🚨 **ACİL DURUM ALARMI (%s)** 🚨\n\n" +
                    "Mesajınızda hayati risk taşıyan kritik semptomlar tespit edildi.\n" +
                    "Yapay zeka yanıtı beklenmeden **EVCİL HAYVANINIZI DERHAL EN YAKIN ACİL VETERİNER KLİNİĞİNE GÖTÜRÜNÜZ**.\n\n" +
                    "İlk Yardım Tavsiyesi:\n" +
                    "- Hayvanı sakin tutun ve hareketini kısıtlayın.\n" +
                    "- Ağız yolunu tıkabilecek yabancı maddeleri kontrol edin (güvenliğiniz için ısırmalara dikkat edin).\n" +
                    "- Kliniğe gitmeden önce veterinerinizi arayarak acil durum bilgisi verin.",
                    emergencyType
            );

            return Optional.of(AiChatResponse.builder()
                    .messageId(UUID.randomUUID())
                    .reply(reply)
                    .disclaimer(EMERGENCY_DISCLAIMER)
                    .emergency(true)
                    .promptVersion(RULE_VERSION)
                    .createdAt(OffsetDateTime.now())
                    .build());
        }

        return Optional.empty();
    }

    /**
     * Sanitizes user input against prompt injection attempts.
     */
    public String sanitizePromptInput(String message) {
        if (message == null) return "";
        String sanitized = message;
        for (String attack : PROMPT_INJECTION_KEYWORDS) {
            sanitized = sanitized.replaceAll("(?i)" + attack, "[FİLTRELENDİ]");
        }
        return sanitized;
    }
}
