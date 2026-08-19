package com.vettrack.api.common.exception;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * QA Bulgu BE-FINDING-03: API hata timestamp alanı UTC ISO-8601 sözleşmesi.
 * Timestamp alanı artık LocalDateTime yerine UTC tabanlı Instant türünde üretilir.
 */
class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    @Test
    @DisplayName("Hata yanıtı timestamp alanı UTC ISO-8601 Instant formatında olmalı ve JSON çıktısı 'Z' içermeli")
    void whenExceptionHandled_thenTimestampIsUtcIso8601WithZ() throws Exception {
        MissingServletRequestParameterException ex =
                new MissingServletRequestParameterException("testParam", "String");

        ResponseEntity<Map<String, Object>> response = handler.handleMissingParams(ex);

        // 1. Nesne tipi kontrolü
        Object timestamp = response.getBody().get("timestamp");
        assertNotNull(timestamp);
        assertInstanceOf(Instant.class, timestamp);

        // 2. JSON serileştirme / PRD sözleşme doğrulaması (Z/UTC kontrolü)
        String jsonOutput = objectMapper.writeValueAsString(response.getBody());
        assertTrue(jsonOutput.contains("Z\"") || jsonOutput.matches(".*\"timestamp\":\"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.*Z\".*"));
    }

    @Test
    @DisplayName("Zorunlu request parametresi eksikse 400 BAD_REQUEST + VALIDATION_ERROR dönmeli")
    void whenRequiredParameterMissing_thenReturns400ValidationError() {
        MissingServletRequestParameterException ex =
                new MissingServletRequestParameterException("clinicId", "UUID");

        ResponseEntity<Map<String, Object>> response = handler.handleMissingParams(ex);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(ErrorCode.VALIDATION_ERROR.name(), response.getBody().get("error"));
        assertTrue(((String) response.getBody().get("message")).contains("clinicId"));
    }

    @Test
    @DisplayName("Path/Query parametresi beklenen tipe dönüştürülemezse 400 BAD_REQUEST + VALIDATION_ERROR dönmeli")
    void whenParameterTypeMismatch_thenReturns400ValidationError() {
        MethodArgumentTypeMismatchException ex = new MethodArgumentTypeMismatchException(
                "not-a-uuid", UUID.class, "id", null, null);

        ResponseEntity<Map<String, Object>> response = handler.handleTypeMismatch(ex);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(ErrorCode.VALIDATION_ERROR.name(), response.getBody().get("error"));
        String message = (String) response.getBody().get("message");
        assertTrue(message.contains("id"));
        assertTrue(message.contains("UUID"));
    }

    @Test
    @DisplayName("Aşırı uzun bir değer tip uyuşmazlığına sebep olursa mesajda 50 karakterden sonrası kırpılmalı")
    void whenTypeMismatchValueIsTooLong_thenMessageTruncatesValue() {
        String hugeValue = "a".repeat(10_000);
        MethodArgumentTypeMismatchException ex = new MethodArgumentTypeMismatchException(
                hugeValue, UUID.class, "id", null, null);

        ResponseEntity<Map<String, Object>> response = handler.handleTypeMismatch(ex);

        String message = (String) response.getBody().get("message");
        assertFalse(message.contains(hugeValue));
        assertTrue(message.contains("a".repeat(50) + "..."));
    }
}