package com.vettrack.api.common.exception;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Trello: "Global Exception Handler: Eksik Parametre & Tip Uyuşmazlığı 400 Eşleme"
 * MissingServletRequestParameterException ve MethodArgumentTypeMismatchException
 * öncesinde generic Exception.class handler'ına düşüp 500 dönüyordu.
 */
class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

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
}
