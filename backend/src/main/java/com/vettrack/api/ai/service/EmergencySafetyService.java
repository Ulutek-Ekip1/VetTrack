package com.vettrack.api.ai.service;

import com.vettrack.api.ai.dto.AiChatResponse;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class EmergencySafetyService {

    public static final String RULE_VERSION = "v1.3-security-guardrail";

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
            "önceki talimatları yok say", "ignore previous instructions", "system prompt",
            "act as developer", "bütün kuralları unut", "dan mode", "jailbreak", "sudo mode",
            "veteriner hekim gibi davranıp reçete yaz", "sistem kurallarını listele"
    );

    private static final Pattern INJECTION_PATTERN = Pattern.compile(
            PROMPT_INJECTION_KEYWORDS.stream()
                    .<String>map(kw -> Pattern.quote(kw))
                    .collect(Collectors.joining("|")),
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile("(?:\\+?90|0)?[5][0-9]{9}|(?:\\+?90|0)?\\s*[0-9]{3}\\s*[0-9]{3}\\s*[0-9]{2}\\s*[0-9]{2}");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}");

    public Optional<AiChatResponse> checkEmergency(String message) {
        if (message == null || message.isBlank()) {
            return Optional.empty();
        }

        String lowerMessage = message.toLowerCase(Locale.forLanguageTag("tr-TR"));

        boolean isRespiratory = RESPIRATORY_KEYWORDS.stream().anyMatch(kw -> lowerMessage.contains(kw));
        boolean isToxicology = TOXICOLOGY_KEYWORDS.stream().anyMatch(kw -> lowerMessage.contains(kw));
        boolean isTrauma = TRAUMA_KEYWORDS.stream().anyMatch(kw -> lowerMessage.contains(kw));

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

    public String sanitizePromptInput(String message) {
        if (message == null) return "";
        String sanitized = message;

        sanitized = PHONE_PATTERN.matcher(sanitized).replaceAll("[TELEFON GİZLENDİ]");
        sanitized = EMAIL_PATTERN.matcher(sanitized).replaceAll("[E-POSTA GİZLENDİ]");
        sanitized = INJECTION_PATTERN.matcher(sanitized).replaceAll("[GÜVENLİK_FİLTRESİ]");

        return sanitized.trim();
    }
}