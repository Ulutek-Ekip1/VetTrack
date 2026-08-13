package com.vettrack.api.common.exception;

import com.vettrack.api.ai.exception.GeminiApiException;
import com.vettrack.api.ai.exception.IdempotencyKeyReusedException;
import com.vettrack.api.storage.FileTooLargeException;
import com.vettrack.api.storage.UnsupportedFileTypeException;

import lombok.extern.slf4j.Slf4j;
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

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleResourceNotFound(ResourceNotFoundException ex) {
        String message = (ex.getMessage() != null && !ex.getMessage().isBlank()) 
                ? ex.getMessage() 
                : "İstenen kaynak bulunamadığı için işlem gerçekleştirilemedi";
        return buildResponse(HttpStatus.NOT_FOUND, "RESOURCE_NOT_FOUND", message);
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<Map<String, Object>> handleConflict(ConflictException ex) {
        return buildResponse(HttpStatus.CONFLICT, "CONFLICT", ex.getMessage());
    }

    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<Map<String, Object>> handleUnauthorized(UnauthorizedException ex) {
        String message = (ex.getMessage() != null && !ex.getMessage().isBlank()) 
                ? ex.getMessage() 
                : "E-posta veya şifre hatalı";
        return buildResponse(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", message);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        return buildResponse(HttpStatus.BAD_REQUEST, "BAD_REQUEST", ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage())
        );

        Map<String, Object> body = createBaseBody(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED");
        body.put("validationErrors", errors);

        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> handleMalformedJson(HttpMessageNotReadableException ex) {
        return buildResponse(HttpStatus.BAD_REQUEST, "MALFORMED_JSON", "İstek gövdesi (JSON) okunamadı veya format hatalı");
    }

    @ExceptionHandler(FileTooLargeException.class)
    public ResponseEntity<Map<String, Object>> handleFileTooLarge(FileTooLargeException ex) {
        return buildResponse(HttpStatus.CONTENT_TOO_LARGE, "FILE_TOO_LARGE", ex.getMessage());
    }

    @ExceptionHandler(UnsupportedFileTypeException.class)
    public ResponseEntity<Map<String, Object>> handleUnsupportedFileType(UnsupportedFileTypeException ex) {
        return buildResponse(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "UNSUPPORTED_FILE_TYPE", ex.getMessage());
    }
    @ExceptionHandler(RoleMismatchException.class)
    public ResponseEntity<Map<String, Object>> handleRoleMismatch(RoleMismatchException ex) {
        return buildResponse(HttpStatus.FORBIDDEN, "ROLE_MISMATCH", ex.getMessage());
    }

    @ExceptionHandler(EditWindowExpiredException.class)
    public ResponseEntity<Map<String, Object>> handleEditWindowExpired(EditWindowExpiredException ex) {
        return buildResponse(HttpStatus.FORBIDDEN, "EDIT_WINDOW_EXPIRED", ex.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, Object>> handleAccessDenied(AccessDeniedException ex) {
        return buildResponse(HttpStatus.FORBIDDEN, "FORBIDDEN", ex.getMessage());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, Object>> handleMaxUploadSize(MaxUploadSizeExceededException ex) {
        return buildResponse(HttpStatus.CONTENT_TOO_LARGE, "FILE_TOO_LARGE", "Dosya boyutu 15MB'ı aşamaz");
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