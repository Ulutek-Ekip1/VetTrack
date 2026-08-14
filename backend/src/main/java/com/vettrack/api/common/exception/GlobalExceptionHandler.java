package com.vettrack.api.common.exception;

import com.vettrack.api.ai.exception.GeminiApiException;
import com.vettrack.api.ai.exception.IdempotencyKeyReusedException;
import com.vettrack.api.storage.FileTooLargeException;
import com.vettrack.api.storage.UnsupportedFileTypeException;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Sözleşmeye bağlı tüm uygulama hataları tek yerden. {@link ErrorCode} kendi HTTP status'unu
     * ve error kodunu (name) taşır — context'e özel kod, throw noktasında ErrorCode ile belirlenir.
     */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, Object>> handleApiException(ApiException ex) {
        ErrorCode code = ex.getErrorCode();
        String message = (ex.getMessage() != null && !ex.getMessage().isBlank())
                ? ex.getMessage()
                : "İşlem gerçekleştirilemedi";
        return buildResponse(code.getStatus(), code.name(), message);
    }

    @ExceptionHandler(GeminiApiException.class)
    public ResponseEntity<Map<String, Object>> handleGeminiApiException(GeminiApiException ex) {
        HttpStatus status = ex.getStatusCode() == 429 ? HttpStatus.TOO_MANY_REQUESTS : HttpStatus.SERVICE_UNAVAILABLE;
        return buildResponse(status, ex.getStatusCode() == 429 ? "TOO_MANY_REQUESTS" : "SERVICE_UNAVAILABLE",
                "Şu an yapay zeka servisimiz yoğun, lütfen birkaç saniye sonra tekrar deneyiniz.");
    }

    @ExceptionHandler(IdempotencyKeyReusedException.class)
    public ResponseEntity<Map<String, Object>> handleIdempotencyConflict(IdempotencyKeyReusedException ex) {
        return buildResponse(HttpStatus.CONFLICT, "IDEMPOTENCY_KEY_REUSED", ex.getMessage());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, Object>> handleDataIntegrityViolation(DataIntegrityViolationException ex) {
        log.warn("Veri bütünlüğü ihlali (DataIntegrityViolationException): {}", ex.getMessage());
        return buildResponse(ErrorCode.CONFLICT.getStatus(), ErrorCode.CONFLICT.name(),
                "Veri bütünlüğü kısıtlaması ihlal edildi (mükerrer kayıt veya geçersiz referans)");
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        return buildResponse(ErrorCode.VALIDATION_ERROR.getStatus(), ErrorCode.VALIDATION_ERROR.name(), ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );

        Map<String, Object> body = createBaseBody(ErrorCode.VALIDATION_ERROR.getStatus(), ErrorCode.VALIDATION_ERROR.name());
        body.put("validationErrors", errors);

        return new ResponseEntity<>(body, ErrorCode.VALIDATION_ERROR.getStatus());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> handleMalformedJson(HttpMessageNotReadableException ex) {
        return buildResponse(ErrorCode.MALFORMED_JSON.getStatus(), ErrorCode.MALFORMED_JSON.name(),
                "İstek gövdesi (JSON) okunamadı veya format hatalı");
    }

    @ExceptionHandler(FileTooLargeException.class)
    public ResponseEntity<Map<String, Object>> handleFileTooLarge(FileTooLargeException ex) {
        return buildResponse(ErrorCode.FILE_TOO_LARGE.getStatus(), ErrorCode.FILE_TOO_LARGE.name(), ex.getMessage());
    }

    @ExceptionHandler(UnsupportedFileTypeException.class)
    public ResponseEntity<Map<String, Object>> handleUnsupportedFileType(UnsupportedFileTypeException ex) {
        return buildResponse(ErrorCode.UNSUPPORTED_FILE_TYPE.getStatus(), ErrorCode.UNSUPPORTED_FILE_TYPE.name(), ex.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, Object>> handleAccessDenied(AccessDeniedException ex) {
        return buildResponse(ErrorCode.FORBIDDEN.getStatus(), ErrorCode.FORBIDDEN.name(), ex.getMessage());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, Object>> handleMaxUploadSize(MaxUploadSizeExceededException ex) {
        return buildResponse(ErrorCode.FILE_TOO_LARGE.getStatus(), ErrorCode.FILE_TOO_LARGE.name(), "Dosya boyutu 15MB'ı aşamaz");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGlobalException(Exception ex) {
        log.error("Unhandled exception caught in GlobalExceptionHandler", ex);
        return buildResponse(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_SERVER_ERROR", "Beklenmeyen bir hata oluştu");
    }

    private Map<String, Object> createBaseBody(HttpStatus status, String error) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", status.value());
        body.put("error", error);
        return body;
    }

    private ResponseEntity<Map<String, Object>> buildResponse(HttpStatus status, String error, String message) {
        Map<String, Object> body = createBaseBody(status, error);
        body.put("message", message);
        return new ResponseEntity<>(body, status);
    }
}
