package com.vettrack.api.common.exception;

import com.vettrack.api.ai.exception.GeminiApiException;
import com.vettrack.api.ai.exception.IdempotencyKeyReusedException;
import com.vettrack.api.storage.FileTooLargeException;
import com.vettrack.api.storage.StorageException;
import com.vettrack.api.storage.UnsupportedFileTypeException;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.time.Instant;
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
        HttpStatus status;
        String errorCode;
        String userMessage;

        if (ex.getStatusCode() == 429) {
            status = HttpStatus.TOO_MANY_REQUESTS;
            errorCode = "TOO_MANY_REQUESTS";
            userMessage = "Yapay zeka servisinin anlık kotası aşıldı. Lütfen birkaç saniye sonra tekrar deneyiniz.";
        } else if (ex.getStatusCode() == 401 || ex.getStatusCode() == 403) {
            status = HttpStatus.SERVICE_UNAVAILABLE;
            errorCode = "AI_AUTH_ERROR";
            userMessage = "Yapay zeka servisi API anahtarı yetkilendirilemedi. Lütfen sistem yapılandırmasını kontrol ediniz.";
        } else {
            status = HttpStatus.SERVICE_UNAVAILABLE;
            errorCode = "SERVICE_UNAVAILABLE";
            userMessage = "Şu an yapay zeka servisimiz yoğun, lütfen birkaç saniye sonra tekrar deneyiniz.";
        }

        return buildResponse(status, errorCode, userMessage);
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

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<Map<String, Object>> handleMissingParams(MissingServletRequestParameterException ex) {
        String message = "'%s' parametresi zorunludur ve istekte gönderilmedi".formatted(ex.getParameterName());
        return buildResponse(ErrorCode.VALIDATION_ERROR.getStatus(), ErrorCode.VALIDATION_ERROR.name(), message);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<Map<String, Object>> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        String requiredType = ex.getRequiredType() != null ? ex.getRequiredType().getSimpleName() : "beklenen tip";
        String message = "'%s' parametresi geçersiz: '%s' değeri %s tipine dönüştürülemedi"
                .formatted(ex.getName(), truncateValue(ex.getValue()), requiredType);
        return buildResponse(ErrorCode.VALIDATION_ERROR.getStatus(), ErrorCode.VALIDATION_ERROR.name(), message);
    }

    /**
     * İstemciden gelen ham değeri hata mesajına gömmeden önce sınırlar — aşırı uzun bir
     * girdi (örn. URL'ye eklenmiş 10.000 karakterlik string) hata mesajında aynen yansımasın diye.
     */
    private String truncateValue(Object value) {
        String stringValue = String.valueOf(value);
        int maxLength = 50;
        return stringValue.length() > maxLength
                ? stringValue.substring(0, maxLength) + "..."
                : stringValue;
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

    /**
     * StorageException'ın önceden hiç dedicated handler'ı yoktu, bu yüzden Supabase Storage'a
     * (örn. eksik/yanlış bucket, ağ hatası) bağlı HER hata generic Exception.class handler'ına
     * düşüp 500 + "Beklenmeyen bir hata oluştu" dönüyordu - hem gerçek nedeni (upstream storage
     * servisi) gizliyor hem de frontend/backend ayrımını imkansızlaştırıyordu.
     */
    @ExceptionHandler(StorageException.class)
    public ResponseEntity<Map<String, Object>> handleStorageException(StorageException ex) {
        log.error("Depolama (Supabase Storage) hatası", ex);
        return buildResponse(ErrorCode.STORAGE_ERROR.getStatus(), ErrorCode.STORAGE_ERROR.name(),
                "Dosya işlenirken depolama servisinde bir sorun oluştu. Lütfen daha sonra tekrar deneyiniz.");
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
        body.put("timestamp", Instant.now());
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